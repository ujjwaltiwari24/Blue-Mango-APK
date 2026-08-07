class AdminConfig {
  // List of authorized admin emails
  static const List<String> adminEmails = [
    'ujjwaltiwari2234@gmail.com',
    // Add other admin emails here
  ];

  // Helper method to check if a user is an admin
  static bool isAdmin(String? email) {
    if (email == null || email.isEmpty) return false;
    return adminEmails.contains(email.toLowerCase().trim());
  }
}