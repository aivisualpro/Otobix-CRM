enum DeploymentEnvironment { local, dev, prod }

class AppConstants {
  // Other constant classes
  static final Roles roles = Roles();
  static final AuctionStatuses auctionStatuses = AuctionStatuses();
  static final BannerStatus bannerStatus = BannerStatus();
  static final BannerTypes bannerTypes = BannerTypes();
  static final BannerViews bannerViews = BannerViews();
  static const List<String> indianStates = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Andaman and Nicobar Islands",
    "Chandigarh",
    "Dadra and Nagar Haveli",
    "Delhi",
    "Jammu and Kashmir",
    "Ladakh",
    "Lakshadweep",
    "Puducherry",
  ];
}

// User roles class
class Roles {
  // Fields
  final String dealer = 'Dealer';
  final String customer = 'Customer';
  final String salesManager = 'Sales Manager';
  final String admin = 'Admin';
  final String leads = 'Lead';
  final String Inspection = 'Inspection';

  final String LEAD = 'Lead';
  final String INSPECTION = 'Inspection';
  final String userStatusPending = 'Pending';
  final String userStatusApproved = 'Approved';
  final String userStatusRejected = 'Rejected';

  List<String> get all => [dealer, customer, salesManager, admin];
}

// Auction statuses class
class AuctionStatuses {
  final String all = 'all';
  final String upcoming = 'upcoming';
  final String live = 'live';
  final String otobuy = 'otobuy';
  final String marketplace = 'marketplace';
  final String liveAuctionEnded = 'liveAuctionEnded';
  final String sold = 'sold';
  final String otobuyEnded = 'otobuyEnded';
  final String removed = 'removed';
}

// Banners class
class BannerStatus {
  final String active = 'Active';
  final String inactive = 'Inactive';
}

// Banners class
class BannerTypes {
  final String header = 'Header';
  final String footer = 'Footer';
}

// Banners class
class BannerViews {
  final String home = 'Home';
  final String sellMyCar = 'Sell My Car';
}
