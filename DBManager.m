#import "DBManager.h"


@implementation DBManager

+(id)sharedManager
{
    static DBManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] initDBManager];
    });
    return sharedMyManager;
}
-(id)initDBManager
{
    if (self = [super init])
    {
        [self createEditableCopyOfSQLIteIfNeeded];
    }
    return self;
}
-(id)init
{
    return [DBManager sharedManager];
}

-(void)createEditableCopyOfSQLIteIfNeeded
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success)
    {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kAppDBName];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        
        if (!success)
        {
            NSAssert1(0, @"Failed to create writable plist file with message '%@'.", [error localizedDescription]);
        }
    }
    
    if (sqlite3_threadsafe() > 0) {
        
        if (sqlite3_shutdown() == SQLITE_OK) {
            int retCode = sqlite3_config(SQLITE_CONFIG_SERIALIZED);
            if (retCode == SQLITE_OK) {
                NSLog(@"Can now use sqlite on multiple threads, using the same connection");
            } else {
                NSLog(@"setting sqlite thread safe mode to serialized failed!!! return code: %d", retCode);
            }
        }
        
    } else {
        NSLog(@"Your SQLite database is not compiled to be threadsafe.");
    }
    
    sqlite3_initialize();
}
-(NSString *)getDBPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:kAppDBName];
}

+(NSMutableArray *)getResultForSQLQuery:(NSString *)strSQLQuery
{
    NSMutableArray *arrResult=[[NSMutableArray alloc]init];
    sqlite3 *database;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *dataBasePath = [documentsDir stringByAppendingPathComponent:kAppDBName];
    
    
    if(sqlite3_open([dataBasePath UTF8String],&database) == SQLITE_OK)
    {
        const char *sqlStatement = [strSQLQuery UTF8String];
        
        sqlite3_stmt *compiledStatement;
        
        if(sqlite3_prepare_v2(database,sqlStatement,-1,&compiledStatement,NULL)==SQLITE_OK)
        {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW)
            {
                NSMutableDictionary *dictResult=[NSMutableDictionary dictionaryWithCapacity:(sqlite3_column_count(compiledStatement)+1)];
                for (int i=0;i<sqlite3_column_count(compiledStatement);i++)
                {
                    id result;
                    
                    if(sqlite3_column_type(compiledStatement,i)==SQLITE_TEXT)
                    {
                        result=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,i)];
                    }
                    else if(sqlite3_column_type(compiledStatement,i) == SQLITE_INTEGER)
                    {
                        result = [NSNumber numberWithInt:(int)sqlite3_column_int(compiledStatement,i)];
                    }
                    else if(sqlite3_column_type(compiledStatement,i) == SQLITE_FLOAT)
                    {
                        result = [NSNumber numberWithFloat:(float)sqlite3_column_double(compiledStatement,i)];
                    }
                    else if(sqlite3_column_type(compiledStatement,i) == SQLITE_BLOB)
                    {
                        result = [UIImage imageWithData:[NSData dataWithBytes:sqlite3_column_blob(compiledStatement,i) length:sqlite3_column_bytes(compiledStatement,i)]];
                    }
                    else if(sqlite3_column_type(compiledStatement,i) == SQLITE_NULL)
                    {
                        result=[NSString stringWithFormat:@" "];
                    }
                    else
                    {
                        const unsigned char *tempresult = sqlite3_column_text(compiledStatement, i);
                        if(tempresult==NULL)
                        {
                            result=@"";
                        }
                        else
                        {
                            result = [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,i)];
                        }
                    }
                    
                    if(result)
                    {
                        [dictResult setObject:result forKey:[NSString stringWithUTF8String:sqlite3_column_name(compiledStatement,i)]];
                    }
                }
                
                [arrResult addObject:dictResult];
            }
            
            sqlite3_finalize(compiledStatement);
        }
        else
        {
            NSLog(@"Error : %s",sqlite3_errmsg(database));
            sqlite3_finalize(compiledStatement);
        }
    }
    
    sqlite3_close(database);
    
    return arrResult;
}

+(BOOL)executeSQLQuery:(NSString *)strSQLQuery
{
    // NSLog(@"The SQL Query:%@",strSQLQuery);
    sqlite3 *database;
    BOOL isSucess=NO;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *dataBasePath = [documentsDir stringByAppendingPathComponent:kAppDBName];
    
    if(sqlite3_open([dataBasePath UTF8String],&database) == SQLITE_OK)
    {
        const char *sqlStatement = [strSQLQuery UTF8String];
        
        sqlite3_stmt *compiledStatement;
        
        if(sqlite3_prepare_v2(database,sqlStatement,-1,&compiledStatement,NULL)==SQLITE_OK)
        {
            if(SQLITE_DONE == sqlite3_step(compiledStatement))
                isSucess=YES;
            else
                 NSLog(@"Error : %s",sqlite3_errmsg(database));
            
            sqlite3_finalize(compiledStatement);
        }
        else
        {
            NSLog(@"Error : %s",sqlite3_errmsg(database));
            sqlite3_finalize(compiledStatement);
            isSucess=NO;
        }
    }
    

    sqlite3_close(database);
    return isSucess;
}



@end
