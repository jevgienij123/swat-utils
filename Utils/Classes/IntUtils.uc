class IntUtils extends Core.Object;

/**
 * Copyright (c) 2014 Sergei Khoroshilov <kh.sergei@gmail.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 * Attempt to map a string digit to its repspective 
 * integer value according to specified base
 * 
 * @param   string Char
 * @param   int Base
 * @return  void
 */
static function int MapStringDigit(string Char, int Base)
{
    local int Digit;

    switch (Caps(Char))
    {
        case "0":
        case "1":
        case "2":
        case "3":
        case "4":
        case "5":
        case "6":
        case "7":
        case "8":
        case "9":
            Digit = int(Char);
            break;
        case "A":
            Digit = 10;
            break;
        case "B":
            Digit = 11;
            break;
        case "C":
            Digit = 12;
            break;
        case "D":
            Digit = 13;
            break;
        case "E":
            Digit = 14;
            break;
        case "F":
            Digit = 15;
            break;
        default:
            return -1;
    }
    // Check if the parsed digit can actually 
    // be a valid integer of the given base
    if (Base > 16 || Digit >= Base)
    {
        return -1;
    }
    return Digit;
}

/**
 * Parse an integer of the given string
 * 
 * @param   string String
 * @param   int Base
 * @return  int
 */
static function int ToInt(string String, int Base)
{
    local int i, Digit, Decimal;

    String = class'StringUtils'.static.Strip(String);
    // Check if this is a negative integer
    if (Left(String, 1) == "-")
    {
        Decimal = -1;
        String = Mid(String, 1);
    }
    // Ignore empty strings
    if (Len(String) == 0)
    {
        return 0;
    }
    // Convert one digit at a time
    for (i = 0; i < Len(String); i++)
    {
        Digit = class'IntUtils'.static.MapStringDigit(Mid(String, i, 1), Base);
        // Unable to parse a digit
        if (Digit == -1)
        {
            return 0;
        }
        Decimal += Digit * Base**(Len(String) - i - 1);
    }
    return Decimal;
}

/**
 * Attempt to map a digit to its respective string representation
 * 
 * @param   int Digit
 * @param   int Base
 * @return  string
 */
static function string MapIntDigit(int Digit, int Base)
{
    if (Base > 16 || Digit >= Base)
    {
        return "";
    }
    switch (Digit)
    {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
            return string(Digit);
        case 10:
            return "A";
        case 11:
            return "B";
        case 12:
            return "C";
        case 13:
            return "D";
        case 14:
            return "E";
        case 15:
            return "F";
        default:
            return  "";
    }
}

/**
 * Convert given integer to a string according to specified base
 * 
 * @param   int Int
 * @param   int Base
 * @return  string
 */
static function string ToString(int Decimal, int Base)
{
    local int i;
    local array<int> Remainder;
    local string String;

    // Divide the decimal by base
    // untill the remainder is less than the base value
    while (Decimal > Base-1)
    {
        Remainder[Remainder.Length] = Decimal % Base;
        Decimal = Decimal / Base;
    }
    // The decimal remainder also goes into the remainder list
    Remainder[Remainder.Length] = Decimal;
    // Convert the remainder digits (in reversed order) 
    // into their respective string values
    for (i = Remainder.Length-1; i >= 0; i--)
    {
        String = String $ class'IntUtils'.static.MapIntDigit(Remainder[i], Base);
    }
    return String;
}

/* vim: set ft=java: */