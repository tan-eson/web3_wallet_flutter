class NFT {
  final String? name;
  final String? image;
  final String? description;

  NFT(this.name, this.image, this.description);

  factory NFT.fromJson(Map<String, dynamic> json) => NFT(
      json['metadata']['name'],
      json['metadata']['image'],
      json['metadata']['description']);
}
