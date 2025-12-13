class DiscountService {
  double calculateDiscount(int count, double price) {
    if (count >= 3) return price * 0.10;
    if (count == 2) return price * 0.07;
    if (count == 1) return price * 0.02;
    return 0;
  }
}
