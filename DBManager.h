#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define kAppDBName @"YourDataBase.sqlite"

@interface DBManager : NSObject
{}

+(id)sharedManager;
-(id)initDBManager;

-(void)createEditableCopyOfSQLIteIfNeeded;
-(NSString *)getDBPath;

+(NSMutableArray *)getResultForSQLQuery:(NSString *)strSQLQuery;
+(BOOL)executeSQLQuery:(NSString *)strSQLQuery;


@end
