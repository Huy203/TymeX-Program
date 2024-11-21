class Product:
  def __init__(self, name, price, quantity):
    self.name = name
    self.price = price
    self.quantity = quantity

def total_of_product(list_product):
  total = 0
  for product in list_product:
    total += product.price * product.quantity
  return total

def find_most_expensive_product(list_product):
  most_expensive = list_product[0]
  for product in list_product:
    if product.price > most_expensive.price:
      most_expensive = product
  return most_expensive.name

def check_product_availability(list_product, product_name):
  for product in list_product:
    if product.name == product_name:
      return True
  return False

def sort_product(list_product, option):
  if option == 1:
    list_product.sort(key=lambda x: x.name)
  elif option == 2:
    list_product.sort(key=lambda x: x.price)
  elif option == 3:
    list_product.sort(key=lambda x: x.quantity)
  return list_product

def main():
  list_product = []
  list_product.append(Product("Laptop", 999.99, 5))
  list_product.append(Product("Smartphone", 499.99, 10))
  list_product.append(Product("Tablet", 299.99, 0))
  list_product.append(Product("Smartwatch", 199.99, 3))

  print("Total of product: ", total_of_product(list_product))
  print("Most expensive product: ", find_most_expensive_product(list_product))
  print("Check product availability: ", check_product_availability(list_product, "Laptop"))

  print("Input options to sort the list of products: ")
  print("1. Sort by name")
  print("2. Sort by price")
  print("3. Sort by quantity")

  user_input = input("Please enter your name: ")
  user_input = int(user_input)

  while True:
    if user_input == 1 or user_input == 2 or user_input == 3:
      sorted_list = sort_product(list_product, user_input)
      print("List of products: ")
      for product in sorted_list:
        print(product.name, product.price, product.quantity)
      break
    else:
      print("Invalid option")

main()