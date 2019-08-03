


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <StoreKit/SKPaymentTransaction.h>

@protocol productPurchasedDelegate <NSObject>
-(void)userHadPurchasedProduct:(SKProductsRequest *)purchasedProdct;
@end


@interface InAppPurchaser : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>{
    SKProductsRequest *productsRequest;
}

- (void)purchaseItem: (NSString*)aStrItemID ;
- (void)restore;

@property(nonatomic, weak)id <productPurchasedDelegate> delegate;

@end
