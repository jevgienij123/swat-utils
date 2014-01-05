class ArrayUtils extends Core.Object;

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
 * Return position of the first array element matching given string
 * If none found, return -1
 *
 * @param   array<string> Array
 * @param   string String
 * @param   bool bIgnoreCase
 * @return  int
 */
static function int Search(array<string> Array, coerce string String, optional bool bIgnoreCase)
{
    local int i;

    for (i = 0; i < Array.Length; i++)
    {
        if (bIgnoreCase && Array[i] ~= String || Array[i] == String)
        {
            return i;
        }
    }
    return -1;
}

/**
 * Tell whether two arrays are of the same length and contain equal strings
 * 
 * @param   array<string> This
 * @param   array<string> Other
 * @return  bool
 */
static function bool Compare(array<string> This, array<string> Other)
{
    local int i;

    if (This.Length != Other.Length)
    {
        return false;
    }
    for (i = 0; i < This.Length; i++)
    {
        if (This[i] != Other[i])
        {
            return false;
        }
    }
    return true;
}

/**
 * Concatenate elements of given array into a string
 * 
 * @param   array<string> Array
 * @param   string Delimiter
 * @return  string
 */
static function string Join(array<string> Array, optional string Delimiter)
{
    local string String;
    local int i;

    for (i = 0; i < Array.Length; i++)
    {
        String = String $ Array[i];

        if (i < Array.Length - 1 && Delimiter != "")
        {
            String = String $ Delimiter;
        }
    }
    return String;
}

/**
 * Return length of given string array
 * 
 * @param   array<string> Array
 * @return  int
 */
static function int Length(array<string> Array)
{
    return Array.Length;
}

/**
 * Return a random element of given array
 *
 * @param   array<string> Array
 * @return  string
 */
static function string Random(array<string> Array)
{
    return Array[Rand(Array.Length)];
}

/* vim: set ft=java: */