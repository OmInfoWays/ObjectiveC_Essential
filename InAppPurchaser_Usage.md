# VishInAppPurchase
InApp Purchase wrapper for iOS. Which provide Purchase &amp; Restore.

// How to use it?
----------------------------------------------------------
1> write below in ypur .m file where you wants to implement InApp purchase.
#import "InAppPurchaser.h"

2> Create Object of InAppPurchaser Class.
@interface YourClass : UIViewController{
 InAppPurchaser *myInAppStore;
 }
 
 3> Make purchase by below.
  
#pragma mark - inApp Purchase Methods
-(void)purchaseItemWithRestore:(BOOL)aBoolRestore{
    
    if (m_InAppStore != nil)
        m_InAppStore = nil;
    
    m_InAppStore = [[InAppPurchaser alloc] init];
    
    [m_InAppStore setDelegate:self];
    
    if (aBoolRestore)
        [m_InAppStore restore];
    else
        [m_InAppStore purchaseItem:unlockAd_inAppPurchaseID];
}
#pragma mark -=== Vish Product Purchased Delegate
-(void)userHadPurchasedProduct:(SKProductsRequest *)purchasedProdct{
    // Product purchase
}

