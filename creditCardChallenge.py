import re

def validateCreditCard(cardNum):
    # '^' represents the start of the string
    # '[456]' matches the first digit of the string to be 4, 5, or 6
    # '[\d]{3}' matches the next three digits to be any digit (0-9)
    # '-?' matches zero or one occurrence of a hyphen
    # '[\d]{4}' matches the next four digits to be any digit (0-9)
    # '$' marks the end of the string
    pattern = re.compile(r"^[456][\d]{3}-?[\d]{4}-?[\d]{4}-?[\d]{4}$")

    # First, the card number is checked to see if it matches the regex pattern.
    # Secondly, the hyphens are removed and the number is re-examined to see if there are sequences
    # of one digit "(\d)\1" followed by itself three more times "{3,}" AKA 4 consecutive digits
    if pattern.match(cardNum) and not re.search(r"(\d)\1{3,}", cardNum.replace("-", "")):
        return "Valid"
    else:
        return "Invalid"

# Prompts for input and immediately renders Valid or Invalid after each input
numCards = int(input("Enter the number of cards to validate: "))
for i in range(numCards):
    cardNum = input("Enter card number: ")
    print(f"{validateCreditCard(cardNum)}")
