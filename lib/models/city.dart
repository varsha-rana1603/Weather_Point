class City {
  bool isSelected;
  final String city;
  final String state;
  final bool isDefault;

  City({
    required this.isSelected,
    required this.city,
    required this.state,
    required this.isDefault});

  //List of cities
  static List<City> citiesList = [
    City(
      isSelected: false,
      city: 'New Delhi',
      state: 'India',
      isDefault: false,
    ),
    City(
        isSelected: false,
        city: 'Bangalore',
        state: 'India',
        isDefault: false
    ),
    City(
      isSelected: false,
      city: 'Gurugram',
      state: 'Haryana',
      isDefault: false,
    ),
    City(isSelected: false,
        city: 'Varanasi',
        state: 'Uttar Pradesh',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Darjeeling',
        state: 'India',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Chennai',
        state: 'India',
        isDefault: false),
    City(isSelected: false,
        city: 'Bhubaneshwar',
        state: 'India',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Jammu & Kashmir',
        state: 'India',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Shimla',
        state: 'India',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Jaipur',
        state: 'India',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Mumbai',
        state: 'Maharashtra',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Hyderabad',
        state: 'Andhra Pradesh',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Kolkata',
        state: 'West Bengal',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Lucknow',
        state: 'Uttar Pradesh',
        isDefault: false
    ),
    City(isSelected: false,
        city: 'Pilani',
        state: 'Rajasthan',
        isDefault: true
    ),
    City(isSelected: false,
        city: 'Goa',
        state: 'Goa',
        isDefault: false
    ),
  ];
}
