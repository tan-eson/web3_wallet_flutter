import 'dart:convert';

/// Could definitely use more properties if needed.
/// This is the only file needed for adding new properties.
class NFT {
  final String name;
  final String image;
  final String description;

  NFT(this.name, this.image, this.description);

  factory NFT.fromJson(Map<String, dynamic> json) {
    final decodedResult = jsonDecode(json['metadata']);

    /// Here we check if image is just an ipfs bucket reference.
    /// Contains http in url would imply url is NOT an ipfs bucket reference
    final processImageUrl = decodedResult!['image'].toString().contains("http")
        ? decodedResult['image'].toString()

        /// remove the first 7 characters
        /// target characters to remove -> "ipfs://"
        : decodedResult?['image'].toString().substring(7);

    final imageUrl = processImageUrl != null
        ? processImageUrl.contains("http")
            ? processImageUrl
            : "https://cloudflare-ipfs.com/ipfs/$processImageUrl"

        /// just a placeholder image
        : "https://images.pexels.com/photos/8473212/pexels-photo-8473212.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load";

    return NFT(
      decodedResult?['name'] ?? "-",
      imageUrl,
      decodedResult?['description'] ?? "-",
    );
  }
}
