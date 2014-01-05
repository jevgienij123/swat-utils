class UnicodeUtils extends Core.Object;

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
 * Encode a string with UTF-8
 *
 * @param   string String
 * @return  array<byte>
 */
static function array<byte> ToUTF8(string String)
{
    local int i, j;
    local array<byte> UTF8Char, UTF8String;

    // Get integer codepoints for each unicode character in the string
    for (i = 0; i < Len(String); i++)
    {
        // And encode it with UTF-8
        UTF8Char = class'UnicodeUtils'.static.UnicodeToUTF8(Asc(Mid(String, i, 1)));
        // Now append encoded array to the main sequence
        for (j = 0; j < UTF8Char.Length; j++)
        {
            UTF8String[UTF8String.Length] = UTF8Char[j];
        }
    }
    return UTF8String;
}

/**
 * Encode unicode code point to a byte sequence with UTF-8
 *
 * http://tools.ietf.org/html/rfc3629
 * 
 * @param   int CodePoint
 * @return  array<byte>
 */
static function array<byte> UnicodeToUTF8(int CodePoint)
{
    local int i;
    local byte LeadingByteMask;
    local array<int> Groups;
    local array<byte> Bytes;
    // Code points 0-127 are UTF-8 encoded using the ASCII table
    // For instance, 65 -> A (Latin Capital A)
    if (CodePoint <= 0x7F)
    {
        Bytes[Bytes.Length] = CodePoint;
        return Bytes;
    }
    // Although UTF-8 can be used to encode up to 2147483648 code points,
    // RFC3629 restricts the limit to 1114112
    else if (CodePoint > 0x10FFFF)
    {
        return Bytes;
    }
    // Split codepoint integer into a group of 6 bits
    // For instance, the codepoint for U+262E character (☮) written in binary notation as 10011000101110
    // would be split into 3 groups: [3:101110] [2:011000] [1:10] (in reversed order)
    while (CodePoint > 0)
    {
        Groups[Groups.Length]= CodePoint & 0x3f;
        CodePoint = CodePoint >> 6;
    }
    // Now compute a leading byte mask
    // For the sequence mentioned above, that would be [11100000]
    // with 1110 bits in high order indicating the number of bytes 
    // in the final sequence followed up by a terminating zero bit
    LeadingByteMask = class'UnicodeUtils'.static.GetUTF8LeadingByte(Groups.Length);
    // Check if the mask can be safely applied to the first byte in the sequence 
    // For instance, 11100000 cannot be applied to first byte if the latter is 00010000 or greater
    if (Groups[Groups.Length-1] > (LeadingByteMask ^ 0xFF) >> 1)
    {
        // In that case compute another leading byte and append it to the sequence standalone 
        // taking into account the fact that the extra byte will increase sequence length
        Groups[Groups.Length] = class'UnicodeUtils'.static.GetUTF8LeadingByte(Groups.Length + 1);
    }
    else
    {
        // Otherwise simply OR it
        Groups[Groups.Length-1] = Groups[Groups.Length-1] | LeadingByteMask;
    }
    // For the final part, unreverse the sequence and OR each byte with 0x80 (10000000)
    // Since this is at min a 2 byte sequence, no harm will be done to the leading byte
    for (i = Groups.Length-1; i >= 0; i--)
    {
        // [3:101110] [2:011000] [1:11100010] -> [1:11100010] [2:10011000] [3:10101110]
        Bytes[Bytes.Length] = Groups[i] | 0x80;
    }
    // Voila!
    return Bytes;
}

/**
 * Return a leading byte mask for a UTF-8 byte sequence of the given length
 * 
 * @param   int Length
 *          Number of bytes in the sequence
 * @return  byte
 */
static function byte GetUTF8LeadingByte(int Length)
{
    // 1. Left-shift 8-Length bits in 0xFF
    // 2. Apply the AND 0xFF mask to the result
    // For instance, compute a leading byte mask for a 3-byte sequence
    // 11111111 << 8-3 = 11111[11100000] & 11111111 = 11100000
    return (0xFF << 8-Length) & 0xFF;
}

/**
 * Decode a utf-8 byte array into a unicode string
 * 
 * @param   array<byte> Bytes
 * @return  string
 */
static function string FromUTF8(array<byte> Bytes)
{
    local int i, j, NumOfBytes, CodePoint;
    local array<string> Chars;

    for (i = 0; i < Bytes.Length; i++)
    {
        // Leave 0-127 as is
        if (Bytes[i] <= 0x7F)
        {
            Chars[Chars.Length] = Chr(Bytes[i]);
        }
        // Treat characters with code point greater than 127
        // as the leading bytes of multibyte sequences
        else
        {
            NumOfBytes = class'UnicodeUtils'.static.GetUTF8NumberOfBytes(Bytes[i]);

            if (NumOfBytes >= 2 && Bytes.Length >= i + NumOfBytes)
            {
                // Define the first portion of the codepoint value
                CodePoint = (((Bytes[i] << NumOfBytes) & 0xFF) >> NumOfBytes);

                for (j = 1; j < NumOfBytes; j++)
                {
                    CodePoint = CodePoint << 6;
                    CodePoint = CodePoint | (Bytes[++i] & 0x3f);
                }
                // Chr seems to be unable to handle codepoints greater than 2047
                if (CodePoint < 2048)
                {
                    Chars[Chars.Length] = Chr(CodePoint);
                }
            }
        }
    }
    return class'ArrayUtils'.static.Join(Chars, "");
}

/**
 * Reencode a utf-8 encoded string
 * 
 * @param   string String
 * @return  string
 */
static function string EncodeUTF8(string String)
{
    local int i;
    local array<byte> Bytes;
    local string Result;

    // Get the string as a utf-8 byte array
    Bytes = class'Utils.UnicodeUtils'.static.ToUTF8(String);
    // Chr the bytes as if they were ASCII characters
    for (i = 0; i < Bytes.Length; i++)
    {
        Result = Result $ Chr(Bytes[i]);
    }
    return Result;
}

/**
 * Redecode a utf-8 encoded string
 * 
 * @param   string String
 * @return  string
 */
static function string DecodeUTF8(string String)
{
    local int i;
    local array<byte> Bytes;

    for (i = 0; i < Len(String); i++)
    {
        Bytes[Bytes.Length] = Asc(Mid(String, i, 1));
    }

    return class'UnicodeUtils'.static.FromUTF8(Bytes);
}

/**
 * Return the number of bytes in a UTF-8 sequence according to its leading byte
 * 
 * @param   byte LeadingByte
 * @return  int
 */
static function int GetUTF8NumberOfBytes(byte LeadingByte)
{
    local int i;

    // Anything lower than 11000000 and higher than 11111101 is not valid
    if (LeadingByte >= 0xC0 && LeadingByte < 0xFE)
    {
        for (i = 0; i < 8; i++)
        {
            if (((LeadingByte >> i) ^ (0xFF >> i)) == 0)
            {
                return 8-i;
            }
        }
    }
    return -1;
}

/* vim: set ft=java: */