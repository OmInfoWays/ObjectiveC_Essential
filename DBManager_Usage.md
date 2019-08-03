# DataBaseManager
DataBaseManager is wrapper for Manage SQlite Database in iOS.

//How to use it?

1> In DBManager.h
#define kAppDBName @"give_Your_DataBase_Name.sqlite"

2> In AppAppDelegate.m Import below,
#import "DBManager.h"

2> In AppAppDelegate.m,
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
/// your code
    
    [DBManager sharedManager];
    
    return YES;
}

4> Write Queries As below,
--- For Get Data :
NSArray *aArraytemp = [DBManager getResultForSQLQuery:aStrGetPlayListQuery];

--- For Update or Insert Data :
[DBManager executeSQLQuery:aStringInsertQuery];



