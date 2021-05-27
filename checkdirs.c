/* 整体思路是对相应的路径进行合法化，然后对当前目录下所有目录进行递归查询，每次查询判断
 * 父目录链接数是否等于子目录的链接数之和加二；
 */
#if defined(__OpenBSD__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__sun) || defined (hpux) || defined (__bsdi__) || defined (bsdi) || defined (__APPLE__)
#include <limits.h>
#elif defined(__APPLE__) && defined(__MACH__)
#include <sys/syslimits.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <dirent.h>
#include <string.h>
#include <errno.h>

#ifndef NAME_MAX
#define NAME_MAX        PATH_MAX
#endif

struct dirinfolist {
    char		dir_name[NAME_MAX+1];
    int			dir_lc;
    struct  dirinfolist *dirlist_next;
};

void usage ();
char* make_pathname(char* path, char* dir, char** buffer);
int check_dirs (char* dir, char* path, int linkcount, int norecurse);

char* make_pathname(char* path, char* dir, char** buffer)
{
    int path_len = strlen(path);
    int buffer_len = 0;
    int pathname_len = path_len + strlen(dir) +2;
    int offset;

    if (!(*buffer) || (sizeof(*buffer) < pathname_len)) 
    {
	if (buffer) free((void*)*buffer);
	buffer_len = (pathname_len > PATH_MAX) ? pathname_len : PATH_MAX;

	if (!(*buffer = (char*)malloc(buffer_len)))
	{
	    fprintf(stderr, "malloc() failed: %s\n", strerror(errno));
	    return (char *)NULL;
	}
    }

    if (dir[0] == '/')
    {
	offset = 0;
    }
    else 
    {
	strncpy(*buffer, path, buffer_len);
	if ((*buffer)[path_len-1] == '/') 
	{
	    offset = path_len;
	}
	else 
	{
	    (*buffer)[path_len] = '/';
	    offset = path_len+1;
	}
    }
    strncpy((*buffer)+offset, dir, buffer_len-offset);
    return (*buffer);
}

int check_dirs (char *dir, char *path, int linkcount, int norecurse)
{
    int diff = -1;
    int numdirs;
    DIR *dirhandle;
    struct dirent *fileinfo;
    struct dirinfolist *dirlist, *dirptr;
    struct stat statinfo;

    int path_len;
    int buffer_len;
    char *cursepath, *path_name;

    /*获得当前默认目录的路径或者目的path的路径 */
    if (!path || !(path_len=strlen(path))) 
    {
	buffer_len = PATH_MAX;
	if (!(cursepath = (char* )malloc(buffer_len)))
	{
	    fprintf(stderr, "malloc() failed: %s\n", strerror(errno));
	    return -1;
	}
	while (!getcwd(cursepath, buffer_len))
	{
	    if (errno == ERANGE)
	    {
		free((void*) cursepath);
		buffer_len = buffer_len * 2;
		if (!(cursepath = (char* )malloc(buffer_len)))
		{
		    fprintf(stderr, "malloc() failed: %s\n", strerror(errno));
		    return -1;
		}
	    }
	    else 
	    {
		fprintf(stderr, "getcwd() failed: %s\n", strerror(errno));
		return -1;
	    }
	}
    }
    else 
    {
	if (!(cursepath = (char*)malloc(path_len+1)))
	{
	    fprintf(stderr, "malloc() failed: %s\n", strerror(errno));
	    return -1;
	}
	strncpy(cursepath, path, path_len+1);
    }

 
    path_name=(char*)NULL;
    if (!make_pathname(cursepath, dir, &path_name))
    {
	fprintf(stderr, "make_pathname() failed: %s\n", strerror(errno));
	free((void*)cursepath);
	return -1;
    }

     

    if (chdir(dir))
    {
	fprintf(stderr, "chdir(%s) : %s\n", path_name,  strerror(errno));
	free((void*)path_name);
	return -1;
    }
    
    if (!linkcount) 
    {
	if (lstat(".", &statinfo)) {
	    fprintf(stderr, "lstat(%s): %s\n", path_name, strerror(errno));
	    return -1;
	}
	linkcount = statinfo.st_nlink;
    }

    if (!(dirhandle = opendir(".")))
    {
	fprintf(stderr, "lstat(%s) failed: %s\n",path_name, strerror(errno));
	free((void *)path_name);
	return -1;
    }

    numdirs=0;
    dirlist = (struct dirinfolist*) NULL;
    while ((fileinfo = readdir(dirhandle))) 
    {
	if (!strcmp(fileinfo->d_name, ".")|| !strcmp(fileinfo->d_name, ".."))
	    continue;

	if (lstat(fileinfo->d_name, &statinfo))
	{
	    fprintf(stderr, "lstat(%s/%s): %s\n", path_name, fileinfo->d_name, strerror(errno));
	    closedir(dirhandle);
	    free((void *)path_name);
	    return -1;

	}

	if (S_ISDIR(statinfo.st_mode))
	{
	    numdirs++;
	    if (norecurse) continue;

	    if (statinfo.st_nlink > 2)
	    {
		dirptr = dirlist;
		if (!(dirlist = (struct dirinfolist*) malloc(sizeof(struct dirinfolist))))
		{
		    fprintf(stderr, "malloc() failed: %s\n", strerror(errno));
		    norecurse = 1;
		    while (dirptr)
		    {
			dirlist = dirptr->dirlist_next;
			free((void*) dirptr);
			dirptr = dirlist;
		    } 
		    continue;
		}
		strncpy(dirlist->dir_name, fileinfo->d_name, sizeof(dirlist->dir_name));
		dirlist->dir_lc = statinfo.st_nlink;
		dirlist->dirlist_next = dirptr;
	    }
	}
    }
    closedir(dirhandle);

    diff = linkcount - numdirs - 2;
    if (diff) printf("%d\t%s\n", diff, path_name);

    while (dirlist) 
    {
	check_dirs(dirlist->dir_name, path_name, dirlist->dir_lc, norecurse);
	dirptr = dirlist->dirlist_next;
	free((void *)dirlist);
	dirlist = dirptr;
    }

    if (chdir(cursepath)) {
	fprintf(stderr, "Final chdir(%s) failed (%s) -- EXIT!\n", cursepath, strerror(errno));
	exit(255);
    }

    free((void *)path_name);
    return(diff);
}


void usage ()
{
    fprintf(stderr, "checkdir [-n] dir ...\n");
    exit(255);
}

int main (int argc, char **argv)
{
    int norecurse = 0;
    int retval = 0;
    int curse = 0;

    /*check curse invaild or not*/
    while ((curse = getopt(argc, argv, "n")) > 0) 
    {
	switch (curse) 
	{
	    case 'n':
		norecurse = 1;
		break;
	    default:
		usage();
	}
    }
    if (argc <= optind) 
    {
	usage();
    }

    for (int i = optind; i < argc; i++)
    {
	retval = check_dirs(argv[i], (char *)NULL, 0, norecurse);
    }

    exit(retval);

}
