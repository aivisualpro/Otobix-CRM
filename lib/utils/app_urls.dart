class AppUrls {
  //   static const String baseUrl = "http://localhost:4000/api/"; // For Localhost
  static const String baseUrl =
      "https://otobix-app-backend-development.onrender.com/api/"; // For Development
  // static const String baseUrl =
  //     "https://ob-dealerapp-kong.onrender.com/api/"; // For Production
  // static const String baseUrl =
  //     "http://192.168.100.99:4000/api/"; // For Mobile Testing

  static const String setMargin = "/auction/set-margin";

  static String get login => "${baseUrl}user/login";

  static String get getBidsSummary => "${baseUrl}admin/bids/summary";

  static String get getRecentBidsList =>
      "${baseUrl}admin/bids/recent-bids-list";

  static String get getDashboardReportsSummary =>
      "${baseUrl}admin/dashboard/get-reports-summary";

  static String get getDashboardDealersByMonth =>
      "${baseUrl}admin/dashboard/get-dealers-by-months";

  static String get getCarsSummaryCounts =>
      "${baseUrl}admin/cars/get-summary-counts";

  static String get getCarsListForCRM => "${baseUrl}admin/cars/get-cars-list";

  static String get getHighestBidsPerCar =>
      "${baseUrl}admin/cars/get-highest-bids-on-car";

  static String get createKam => "${baseUrl}admin/kams/create";

  static String get getKamsList => "${baseUrl}admin/kams/get-list";

  static String get updateKam => "${baseUrl}admin/kams/update";

  static String get deleteKam => "${baseUrl}admin/kams/delete";

  static String get assignKamToDealer =>
      "${baseUrl}admin/kams/assign-to-dealer";

  static String get getCustomersSummary =>
      "${baseUrl}admin/customers/get-summary-counts";

  static String get getCarDropdownsList =>
      "${baseUrl}admin/customers/car-dropdowns/get-list";

  static String get addCarDropdown =>
      "${baseUrl}admin/customers/car-dropdowns/add";

  static String get editCarDropdown =>
      "${baseUrl}admin/customers/car-dropdowns/edit";

  static String get deleteCarDropdown =>
      "${baseUrl}admin/customers/car-dropdowns/delete";

  static String get toggleCarDropdownStatus =>
      "${baseUrl}admin/customers/car-dropdowns/toggle-status";

  static String get addBanner => "${baseUrl}admin/banners/add";

  static String get fetchBannersList => "${baseUrl}admin/banners/get-list";

  static String get deleteBanner => "${baseUrl}admin/banners/delete";

  static String get fetchBannersCount => "${baseUrl}admin/banners/get-count";

  static String get updateBannerStatus =>
      "${baseUrl}admin/banners/update-status";

  static String get getApprovedDealersList =>
      "${baseUrl}admin/dealers/get-approved-dealers-list";

  // New routes
  static String get sendOtp => "${baseUrl}otp/send-otp";

  static String get verifyOtp => "${baseUrl}otp/verify-otp";

  static String get fetchDetails => "${baseUrl}otp/fetch-details";

  static String get register => "${baseUrl}user/register";

  static String get setNewPassword => "${baseUrl}user/set-new-password";

  static String get allUsersList => "${baseUrl}user/all-users-list";

  static String get approvedUsersList => "${baseUrl}user/approved-users-list";

  static String get pendingUsersList => "${baseUrl}user/pending-users-list";

  static String get rejectedUsersList => "${baseUrl}user/rejected-users-list";

  static String get usersLength => "${baseUrl}user/users-length";

  static String get updateProfile => "${baseUrl}user/update-profile";

  static String get getUserProfile => "${baseUrl}user/user-profile";

  static String checkUsernameExists(String username) =>
      "${baseUrl}user/check-username?username=$username";

  static String updateUserStatus(String userId) =>
      "${baseUrl}user/update-user-status/$userId";

  static String getUserStatus(String userId) =>
      "${baseUrl}user/user-status/$userId";

  static String logout(String userId) => "${baseUrl}user/logout/$userId";

  static String getCarDetails(String carId) => "${baseUrl}car/details/$carId";

  static String getCarsList({required String auctionStatus}) =>
      "${baseUrl}car/cars-list?auctionStatus=$auctionStatus";

  static String get getCarDetailsForNotification =>
      "${baseUrl}car/get-cars-list-model-for-a-car";

  static String get getAuctionStatusAndRemainingTime =>
      "${baseUrl}car/get-car-auction-status-and-remaining-time";

  static String updateUserThroughAdmin(String userId) =>
      "${baseUrl}user/update-user-through-admin/?userId=$userId";

  static String get updateCarBid => "${baseUrl}car/update-bid";

  static String get updateCarAuctionTime => "${baseUrl}car/update-auction-time";

  static String get schedulAuction =>
      "${baseUrl}upcoming/update-car-auction-time";

  static String get checkHighestBidder => "${baseUrl}car/check-highest-bidder";

  static String get submitAutoBidForLiveSection =>
      "${baseUrl}car/submit-auto-bid-for-live-section";

  static String get userNotifications =>
      "${baseUrl}user/notifications/create-notification";

  static String userNotificationsList({
    required String userId,
    required int page,
    required int limit,
  }) =>
      "${baseUrl}user/notifications/notifications-list?userId=$userId&page=$page&limit=$limit";

  static String userNotificationsDetail({
    required String userId,
    required String notificationId,
  }) =>
      "${baseUrl}user/notifications/notification-details?userId=$userId&notificationId=$notificationId";

  static String get userNotificationsMarkRead =>
      "${baseUrl}user/notifications/mark-notification-as-read";

  static String get userNotificationsMarkAllRead =>
      "${baseUrl}user/notifications/mark-all-notifications-as-read";

  static String userNotificationsUnreadNotificationsCount({
    required String userId,
  }) =>
      "${baseUrl}user/notifications/get-unread-notifications-count?userId=$userId";

  static String getUserWishlist({required String userId}) =>
      "${baseUrl}user/get-user-wishlist?userId=$userId";

  static String get addToWishlist => "${baseUrl}user/add-to-wishlist";

  static String get removeFromWishlist => "${baseUrl}user/remove-from-wishlist";

  static String getUserWishlistCarsList({required String userId}) =>
      "${baseUrl}user/get-user-wishlist-cars-list?userId=$userId";

  static String getUserMyBidsList({required String userId}) =>
      "${baseUrl}user/get-user-my-bids?userId=$userId";

  static String get addToMyBids => "${baseUrl}user/add-to-my-bids";

  static String get removeFromMyBids => "${baseUrl}user/remove-from-my-bids";

  static String getUserMyBidsCarsList({required String userId}) =>
      "${baseUrl}user/get-user-my-bids-cars-list?userId=$userId";

  static String getUserBidsForCar({
    required String userId,
    required String carId,
  }) =>
      "${baseUrl}user/get-user-bids-for-car?userId=$userId&carId=$carId";

  static String get uploadTermsAndConditions => "${baseUrl}terms/upload";

  static String get getLatestTermsAndConditions => "${baseUrl}terms/latest";

  static String get uploadPrivacyPolicy => "${baseUrl}privacy-policy/upload";

  static String get getLatestPrivacyPolicy => "${baseUrl}privacy-policy/latest";

  static String get uploadDealerGuide => "${baseUrl}dealer-guide/upload";

  static String get getLatestDealerGuide => "${baseUrl}dealer-guide/latest";

  static String get moveCarToOtobuy => "${baseUrl}otobuy/move-car-to-otobuy";

  static String get buyCar => "${baseUrl}otobuy/buy-car";

  static String get makeOfferForCar => "${baseUrl}otobuy/make-offer-for-car";

  static String get markCarAsSold => "${baseUrl}otobuy/mark-car-as-sold";

  static String get removeCar => "${baseUrl}car/remove-car";

  static String get getEntityNamesList =>
      "${baseUrl}entity-documents/get-entity-names-list";

  // Socket URL Extraction
  static final String socketBaseUrl = _extractSocketBaseUrl(
    baseUrl,
  ); // Socket base URL
  static String _extractSocketBaseUrl(String url) {
    final uri = Uri.parse(url);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }
}
