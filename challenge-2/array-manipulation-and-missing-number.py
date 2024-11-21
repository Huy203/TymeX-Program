def missing_number(list_number):
    n = len(list_number) + 1
    total = n * (n + 1) // 2
    return total - sum(list_number) 

def main():
    while True:
        n = int(input("Please enter length of numbers: "))
        if(n <= 0):
            print("Please enter a positive number")
            continue
        list_number = []
        for i in range(n):
            number = int(input("Please enter %d number: " % (i + 1)))
            list_number.append(number)

        if(len(list_number) == 0):
            print("Please enter at least one number")
            continue

        print("Missing number: ", missing_number(list_number))
        break

main()