class StringUtils extends Core.Object;

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
 * Tell whether given string contains numeric characters only
 * 
 * @param   string String
 * @return  bool
 */
static function bool IsDigit(string String)
{
    local int i;
    local int Char;

    while (i < Len(String))
    {
        Char = Asc(Mid(String, i, 1));
        
        if (Char < 48 || Char > 57)
        {
            return false;
        }
        i++;
    }
    return Len(String) > 0;
}

/**
 * Left-justify a string in a field of given length
 * By default string will be justified by a white space character
 * 
 * @param   string String
 * @param   int Width
 * @param   string FillChar (optional)
 * @return  string
 */
static function string LJust(coerce string String, int Width, optional string FillChar)
{
    if (FillChar == "")
    {
        FillChar = " ";
    }
    while (Len(String) < Width)
    {
        String = String $ FillChar;
    }
    return String;
}

/**
 * Right-justify a string in a field of given length
 * By default string will be justified by a white space character
 * 
 * @param   string String
 * @param   int Width
 * @param   string FillChar (optional)
 * @return  string
 */
static function string RJust(coerce string String, int Width, optional string FillChar)
{
    if (FillChar == "")
    {
        FillChar = " ";
    }
    while (Len(String) < Width)
    {
        String = FillChar $ String;
    }
    return String;
}

/**
 * Return a copy of the string with leading whitespace characters removed
 * 
 * @param   string String
 * @param   string Chars (optional)
 *          A set of characters the given string should be cleared off
 *          Default: \t, \n, \r and a whitespace character
 * @return  string
 */
static function string LStrip(coerce string String, optional string Chars)
{
    if (Chars == "")
    {
        Chars = " \t\n\r";
    }
    while (InStr(Chars, Left(String, 1)) >= 0 && Len(String) > 0)
    {
        String = Right(String, Len(String) - 1);
    }
    return String;
}

/**
 * Return a copy of the string with trailing whitespace characters removed
 * 
 * @param   string String
 * @param   string Chars (optional)
 *          A set of characters the given string should be cleared off
 *          Default: \t, \n, \r and a whitespace character
 * @return  string
 */
static function string RStrip(coerce string String, optional string Chars)
{
    if (Chars == "")
    {
        Chars = " \t\n\r";
    }
    while (InStr(Chars, Right(String, 1)) >= 0 && Len(String) > 0)
    {
        String = Left(String, Len(String) - 1);
    }
    return String;
}

/**
 * Return a copy of the string with both leading and trailing whitespace characters removed
 * 
 * @param   string String
 * @param   string Chars (optional)
 *          A set of characters the given string should be cleared off
 *          Default: \t, \n, \r and a whitespace character
 * @return  string
 */
static function string Strip(coerce string String, optional string Chars)
{
    if (Chars == "")
    {
        Chars = " \t\n\r";
    }
    return class'StringUtils'.static.LStrip(class'StringUtils'.static.RStrip(String, Chars), Chars);
}

/**
 * Generate a string of given length containing random character set elements
 * 
 * @param   int Length
 *          Required string length
 * @param   string Set (optional)
 *          Source collection of characters used to generate a random string
 *          This argument may also contain a space separated list of predefined list 
 *          of characters such as :alnum: :punct: :lower: :upper: :alpha: :digit: :space:
 * @return  string
 * @example $ RandomString(10)
 *          #4kL)vYw0+
 *          $ RandomString(6, "abcz")
 *          zbcaza
 *          $ RandomString(8, ":punct: abc 456")
 *          (>-b#{-`5
 *          $ RandomString(12, ":upper: :digit:")
 *          DLC26JKW1MCP
 */
static function string Random(int Length, optional string Set)
{
    local int i;
    local array<string> Sets;
    local string Str, Charset;
    local string set_lower, set_upper, set_digit, set_punct, set_space;

    set_lower = "abcdefghijklmnopqrstuvwxyz";
    set_upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    set_digit = "0123456789";
    set_punct = "`^~<=>|_-,;:!?/.'\"()[]{}@$*\&#%+";
    set_space = " ";
    
    Set = class'StringUtils'.static.Strip(Set);
    // if the set argument is empty, use the default sets
    // ie alphanumeric and punctuation characters
    if (Set == "")
    {
        Sets[0] = ":alnum:";
        Sets[1] = ":punct:";
    }
    else
    {
        // Spits sets by a space
        Sets = class'StringUtils'.static.Part(Set);
    }
    for (i = 0; i < Sets.Length; i++)
    {
        switch (Sets[i])
        {
            case ":lower:" :
                Charset = Charset $ set_lower;
                break;
            case ":upper:" :
                Charset = Charset $ set_upper;
                break;
            case ":alpha:" :
                Charset = Charset $ set_lower $ set_upper;
                break;
            case ":digit:" :
                Charset = Charset $ set_digit;
                break;
            case ":alnum:" :
                Charset = Charset $ set_lower $ set_upper $ set_digit;
                break;
            case ":punct:" :
                Charset = Charset $ set_punct;
                break;
            case ":space:" :
                Charset = Charset $ set_space;
                break;
            // as is
            default :
                Charset = Charset $ Sets[i];
        }
    }
    while (Len(Str) < Length)
    {
        Str = Str $ Mid(Charset, Rand(Len(Charset)), 1); // not Len(Charset)-1!
    }
    return Str;
}

/**
 * Replace all occurrences of Replace with With in the string
 * 
 * @param   string String
 * @param   string Replace
 * @param   string With
 * @return  string
 */
static function string Replace(coerce string String, coerce string Replace, coerce string With)
{
    local int i;
    local string Result;

    if (Replace != "")
    {
        while (True)
        {
            i = InStr(String, Replace);
            // No more occurrences have been found, stop
            if (i == -1)
            {
                break;
            }
            Result = Result $ Left(String, i) $ With;
            String = Mid(String, i + Len(Replace));
        }
    }

    return Result $ String;
}

/**
 * Split string into words separated by optional delimiter
 *
 * @param   string String
 * @param   string Delimiter
 * @return  array<string>
 */
static function array<string> Part(string String, optional string Delimiter)
{
    local int j;
    local array<string> Array;
    local string Word;

    // Split by whitespace if none specified
    if (Delimiter == "")
    {
        Delimiter = " ";
    }
    // sanity check
    if (String != "")
    {
        while (True)
        {
            j = InStr(String, Delimiter);

            if (j >= 0)
            {
                Word = Left(String, j);
                // append the string located to the left of the found separator position
                Array[Array.Length] = Word;
                // cut the processed string along with the separator from the original string
                String = Mid(String, Len(Word) + Len(Delimiter));
                continue;
            }
            break;
        }
    }
    // Add the remainder
    Array[Array.Length] = String;
    return Array;
}

/**
 * Split a string into a list of words with at least one character
 * 
 * @param   string String
 * @param   string Delimiter (optional)
 * @return  array<string>
 */
static function array<string> SplitWords(string String, optional string Delimiter)
{
    local int i;
    local array<string> Words;

    Words = class'StringUtils'.static.Part(String, Delimiter);

    for (i = Words.Length-1; i >= 0; i--)
    {
        // Remove leading and trailing white space
        Words[i] = class'StringUtils'.static.Strip(Words[i]);

        if (Words[i] == "")
        {
            Words.Remove(i, 1);
        }
    }

    return Words;
}

/**
 * Parse an IP address from a network address written using ip:port notation
 * 
 * @param   string RawIP
 *          x.x.x.x:yyyyy
 * @return  x.x.x.x
 */
static function string ParseIP(string HostAddr)
{
    return Left(HostAddr, InStr(HostAddr, ":"));
}

/**
 * Interpolate a string with arguments: %1, %2, %3, %4 etc
 * 
 * @param   string String
 * @param   array<string> Arguments
 * @return  string
 */
static function string Sprintf(string String, array<string> Arguments)
{
    local int i;

    for (i = 0; i < Arguments.Length; i++)
    {
        String = class'StringUtils'.static.Replace(String, "%" $ (i+1), Arguments[i]);
    }

    return String;
}

/**
 * Substitute %1, %2, %3, %4, %5 tokens in given string with corresponding arguments
 * 
 * @param   string String
 * @param   string Arg1 (optional)
 * @param   string Arg2 (optional)
 * @param   string Arg3 (optional)
 * @param   string Arg4 (optional)
 * @param   string Arg5 (optional)
 * @return  string
 */
static function string Format(
    string String, 
    optional coerce string Arg1, 
    optional coerce string Arg2, 
    optional coerce string Arg3,
    optional coerce string Arg4, 
    optional coerce string Arg5
)
{
    if (Arg1 != "")
    {
        String = class'StringUtils'.static.Replace(String, "%1", Arg1);
    }
    if (Arg2 != "")
    {
        String = class'StringUtils'.static.Replace(String, "%2", Arg2);
    }
    if (Arg3 != "")
    {
        String = class'StringUtils'.static.Replace(String, "%3", Arg3);
    }
    if (Arg4 != "")
    {
        String = class'StringUtils'.static.Replace(String, "%4", Arg4);
    }
    if (Arg5 != "")
    {
        String = class'StringUtils'.static.Replace(String, "%5", Arg5);
    }
    return String;
}

/**
 * Replace the consecutive characters \ n with a newline
 * 
 * @param   string Str
 * @return  string
 */
static function string NormNewline(coerce string String)
{
    return class'StringUtils'.static.Replace(String, "\\n", "\n");
}

/**
 * Replace the characters \t, \n, \r with a space
 * 
 * @param   string String
 * @return  string
 */
static function string NormSpace(coerce string String)
{
    String = class'StringUtils'.static.Replace(String, "\t", " ");
    String = class'StringUtils'.static.Replace(String, "\r", " ");
    String = class'StringUtils'.static.Replace(String, "\n", " ");
    return String;
}

/**
 * Remove the whitespace characters \t, \r, \n and a space from String
 * 
 * @param   string String
 * @return  string
 */
static function string DropSpace(coerce string String)
{
    String = class'StringUtils'.static.Replace(String, " ", "");
    String = class'StringUtils'.static.Replace(String, "\t", "");
    String = class'StringUtils'.static.Replace(String, "\r", "");
    String = class'StringUtils'.static.Replace(String, "\n", "");
    return String;
}

/**
 * Format a chat message
 * 
 * @param   string Msg
 * @param   Color
 * @return  string
 */
static function string FormatChatMessage(coerce string Msg, optional string Color)
{
    // Make yellow the default color
    if (Color == "")
    {
        Color = "FFFF00";
    }

    Color = "[c=" $ Color $ "]";

    Msg = class'StringUtils'.static.NormNewline(Msg);
    // Restore the original color after closing [\c]'s
    Msg = class'StringUtils'.static.Replace(Msg, "[\\c]", "[\\c]" $ Color);
    // Also restore color after a \n
    Msg = class'StringUtils'.static.Replace(Msg, "\n", "\n" $ Color);

    return Color $ Msg;
}

/**
 * Return a string with text decoration codes stripped off
 * 
 * @param   string String
 *          Potentially decorated text
 * @return  string
 */
static function string Filter(string String)
{
    local string StringLower;
    local int j;

    // Search for the following patterns: 
    // [cC=xxxxx], [bB], [uU], [\\bB], [\uU], [\cC]
    // If one of these is found, then perform a subsitution and do another run
    while (True)
    {
        StringLower = Lower(String);
        // Search for a "[c=""
        j = InStr(StringLower, "[c=");
        // and then the closing bracket "]"" with 6 characters between
        if (j >= 0 && Mid(StringLower, j + 9, 1) == "]")
        {
            String = Left(String, j) $ Mid(String, j + 10);
        }
        else if (InStr(StringLower, "[b]") >= 0)
        {
            String = class'StringUtils'.static.Replace(String, "[b]", "");
            String = class'StringUtils'.static.Replace(String, "[B]", "");
        }
        else if (InStr(StringLower, "[\\b]") >= 0)
        {
            String = class'StringUtils'.static.Replace(String, "[\\b]", "");
            String = class'StringUtils'.static.Replace(String, "[\\B]", "");
        }
        else if (InStr(StringLower, "[u]") >= 0)
        {
            String = class'StringUtils'.static.Replace(String, "[u]", "");
            String = class'StringUtils'.static.Replace(String, "[U]", "");
        }
        else if (InStr(StringLower, "[\\u]") >= 0)
        {
            String = class'StringUtils'.static.Replace(String, "[\\u]", "");
            String = class'StringUtils'.static.Replace(String, "[\\U]", "");
        }
        else if (InStr(StringLower, "[\\c]") >= 0)
        {
            String = class'StringUtils'.static.Replace(String, "[\\c]", "");
            String = class'StringUtils'.static.Replace(String, "[\\C]", "");
        }
        else
        {
            break;
        }
        continue;
    }
    return String;
}

/**
 * Tell whether a string matches a wildcard pattern
 * 
 * The following constructions are valid pattern expressions:
 *     1. * - match zero or more characters
 *     2. (foo|bar|baz) - attempt to match either of the expressions
 *                        enclosed in parentheses and separated by a "|"
 *
 * Pattern lookup is performed in case insensitive manner
 *     For instance, "hello, *" would match against "HELLO, WORLD", as well as "HeLlO, mate"
 * 
 * Examples:
 *     "(hi|hello) *again*" would match:
 *         hi again, hello all again, hello again, etc
 *     "*(bb|bye|goodbye|see y*|night) *(all|guys)*" would match against:
 *         im off bb all, bb guys, good night all, see you guys, see ya all, etc
 *         
 * @param   string String
 *          Test string
 * @param   string Pattern
 *          Wildcard pattern
 * @return  bool
 */
static function bool Match(coerce string String, coerce string Pattern)
{
    local int i, j, n;
    local int StringLength;
    local string GrpLeft, GrpRight;
    local string StringLeft;
    local string PatternLeft, PatternMiddle, PatternRight;
    local array<string> Groups;

    // Split a pattern like (hi|hey|hello) (all|guys)! into several simple patterns
    // testing every split subpattern individually
    // For instance, the pattern mentioned above, on the first run
    // will be tested against given string using the following subpatterns: 
    // hi (all|guys)!, hey (all|guys)!, hello (all|guys)!
    // Further recursive function calls will split the second group into more subpatterns

    Groups = class'StringUtils'.static.ParseGroups(Pattern, GrpLeft, GrpRight);

    if (Groups.Length > 0)
    {
        for (i = 0; i < Groups.Length; i++)
        {
            if (class'StringUtils'.static.Match(String, GrpLeft $ Groups[i] $ GrpRight))
            {
                return true;
            }
        }
        return false;
    }

    StringLength = Len(String);
    // Fix double consecutive *'s
    Pattern = class'StringUtils'.static.Replace(Pattern, "**", "*");
    // Only perform further lookup if the string is at least as long as *-less pattern
    // For instance, "hello world" would have chance to match against "*some quite long pattern*""
    // since its almost the half of the pattern's size
    if (Len(class'StringUtils'.static.Replace(Pattern, "*", "")) > StringLength)
    {
        return false;
    }

    String = Caps(String);
    Pattern = Caps(Pattern);

    while (True)
    {
        // Find the first occurrence of a *
        i = InStr(Pattern, "*");
        // Stop if none found
        if (i == -1)
        {
            break;
        }
        // Capture pattern text on sides from the asterisk
        PatternLeft = Left(Pattern, i);  // noo*b -> noo
        PatternRight = Mid(Pattern, i + 1);  // noo*b -> b
        // Left capture a portion of the test string 
        // of the same size as the pattern's left part
        StringLeft = Left(String, Len(PatternLeft));  // noooob -> noo
        // If this * was at the end of the pattern, then next portion of the string
        // to be tested against the pattern would extend up to its very end
        if (i == Len(Pattern) - 1)
        {
            n = StringLength;
        }
        // Otherwise, only a small part of the string would be tested
        // As small as the part of the pattern enclosed between the current and the next asterisks
        else
        {
            j = InStr(PatternRight, "*");
            // If there are no other asterisks in the pattern,
            // Test it against the remaining pattern part
            if (j == -1)
            {
                PatternMiddle = PatternRight;
            }
            else
            {
                PatternMiddle = Left(PatternRight, j);
            }
            // Now attempt to find the pattern part in the test string's remaining part with
            // everything between the beginning of the remaining string and the found position
            // is considered to be a wildcard matching zero to more characters
            n = InStr(class'StringUtils'.static.Replace(String, StringLeft, ""), PatternMiddle);
        }
        // The right part of the string does not match the pattern's middle part
        if (n == -1)
        {
            return false;
        }
        // Remove characters matching the first asterisk
        String = StringLeft $ Mid(String, n + Len(StringLeft));  // noooob -> noo + b
        // Remove the asterisk from the pattern string
        Pattern = PatternLeft $ PatternRight;  // noo*b -> noob
    }
    // Compare the processed strings
    if (String == Pattern)
    {
        // noooob -> NOOB == noo*b -> NOOB
        return true;
    }
    return false;
}

/**
 * Attempt to find and parse the nearest multiple choice group
 * 
 * @param   string Pattern
 *          Original pattern
 * @param   array<string> Groups (out)
 *          Members of the nearest group
 * @param   string GroupLeft (out)
 *          Portion of the pattern that precedes the nearest group
 * @param   string GroupRight (out)
 *          Portion of the pattern that follows the nearest group
 * @return  array<string>
 */
static function array<string> ParseGroups(string Pattern, out string GroupLeft, out string GroupRight)
{
    local int i, j;
    local string Middle;
    local array<string> Empty;

    GroupLeft = "";
    GroupRight = "";

    i = InStr(Pattern, "(");
    // Find an opening parenthesis
    if (i >= 0)
    {
        // good (evening|night) all -> (evening|night) all
        Middle = Mid(Pattern, i);

        j = InStr(Middle, ")");
        // Delimit the middle part
        if (j >= 0)
        {
            Middle = Left(Middle, j + 1);  // (evening|night) all -> (evening|night)
            GroupLeft = Left(Pattern, i);  // good
            GroupRight = class'StringUtils'.static.Replace(Pattern, GroupLeft $ Middle, "");  // all
            // Remove the parentheses and split groups with a |
            Middle = Mid(Middle, 1, Len(Middle) - 2);  // (evening|night) -> evening|night
            
            return class'StringUtils'.static.Part(Middle, "|"); 
        }
    }
    return Empty;
}

/**
 * Return a copy of String with only its first character capitalized
 *
 * @param   string String
 * @return  string
 */
static function string Capitalize(string String)
{
    return Caps(Mid(String, 0, 1)) $ Mid(String, 1);
}

/**
 * Return a copy of String with n charcters following the leftmost comma
 * 
 * @param   string String
 * @return  string
 */
static function string Round(coerce string String, optional int n)
{
    local int i;

    i = InStr(String, ".");

    if (i != -1)
    {
        if (n <= 0)
        {
            return Left(String, i);
        }
        return Left(String, i+n+1);
    }
    return String;
}

/* vim: set ft=java: */