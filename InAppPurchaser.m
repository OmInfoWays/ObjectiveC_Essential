
#import "InAppPurchaser.h"
#import "SVProgressHUD.h"

@implementation InAppPurchaser

#pragma mark -========= Life Cycle
-(id) init
{
    if (self = [super init])
    {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    }
    return self;
}

#pragma mark -========= Item Purchase & Restore
- (void)purchaseItem: (NSString*)aStrItemID{
    NSLog(@"User requests for Item : %@", aStrItemID);
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:aStrItemID]];
        productsRequest.delegate = self;
        [productsRequest start];
    }
    else{
        //this is called the user cannot make payments, most likely due to parental controls
        NSLog(@"User cannot make payments due to parental controls");
    }
}

- (void) restore{
    
    if ([[[SKPaymentQueue defaultQueue] transactions] count]) {
        
        NSLog(@"We get very non-patient user");
        
        for (SKPaymentTransaction *transaction in [[SKPaymentQueue defaultQueue] transactions])
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }else{
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
}

#pragma mark -========= SKRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = (int)[response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        
        NSLog(@"Name: %@ - Price: %f",[validProduct localizedTitle],[[validProduct price] doubleValue]);
        NSLog(@"Product identifier: '%@'", [validProduct productIdentifier]);
        
        [self purchase:validProduct];
    }
    else if(!validProduct){
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
        NSLog(@"No products available");
    }
}

#pragma mark -========= SKPaymentTransactionObserver
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i", (int)queue.transactions.count);
    
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            
            //called when the user successfully restores a purchase
            
            NSLog(@"Transaction state -> Restored");
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            [self afterSuccess];
            
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    
    for(SKPaymentTransaction *transaction in transactions){
        switch( (NSInteger)transaction.transactionState ){
                
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Transaction state -> Purchasing");
                break;
                
            case SKPaymentTransactionStatePurchased:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                [self afterSuccess];
                
                NSLog(@"Transaction state -> Purchased");
            }break;
                
            case SKPaymentTransactionStateRestored:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                [self afterSuccess];
                
                NSLog(@"Transaction state -> Restored");
            }break;
                
            case SKPaymentTransactionStateFailed:
            {
                if(transaction.error.code == SKErrorPaymentCancelled){
                    //a user cancelled the payment ;(
                    NSLog(@"Transaction state -> Cancelled");
                }
                
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
            }break;
        }
    }
}


- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark -========= Customisation.

-(void)afterSuccess{
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isfullPackPurchased"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if([self.delegate respondsToSelector:@selector(userHadPurchasedProduct:)])
        [self.delegate userHadPurchasedProduct:productsRequest];
}
-(void)dealloc
{
    productsRequest.delegate = nil;
    productsRequest = nil;

    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}
@end
