class LevelUtils extends Core.Object;

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

struct sTime
{
    var float TimeSeconds;
    var int Year;
    var int Month;
    var int Day; 
    var int DayOfWeek;
    var int Hour;
    var int Minute;
    var int Second;
    var int Millisecond; 
};

/**
 * Return an array of players currently logged into admin
 *
 * @param   class'LevelInfo' Level
 *          Reference to the current Level instance
 * @return  array<class'PlayerController'>
 */
static function array<PlayerController> GetAdmins(Engine.LevelInfo Level)
{
    local array<PlayerController> Admins;
    local PlayerController PC;

    foreach Level.DynamicActors(class'PlayerController', PC)
    {
        if (SwatGameInfo(Level.Game).Admin.IsAdmin(PC))
        {
            Admins[Admins.Length] = PC;
        }
    }
    return Admins;
}

/**
 * Return a sTime struct corresponding to the current server time
 *
 * @param   class'LevelInfo' Level
 *          Reference to the current Level instance
 * @return  struct'sTime'
 */
static function sTime GetTime(Engine.LevelInfo Level)
{
    local sTime CurrentTime;

    CurrentTime.TimeSeconds = Level.TimeSeconds;
    CurrentTime.Year = Level.Year;
    CurrentTime.Month = Level.Month;
    CurrentTime.Day = Level.Day;
    CurrentTime.DayOfWeek = Level.DayOfWeek;
    CurrentTime.Hour = Level.Hour;
    CurrentTime.Minute = Level.Minute;
    CurrentTime.Millisecond = Level.Millisecond;

    return CurrentTime;
}

/**
 * Return current time formatted according to the format
 * If not provided use the default format: "%y/%m/%d %H:%M:%S
 * 
 * @param   string Format
 * @return  string
 */
static function string FormatTime(sTime Time, optional string Format)
{
    if (Format == "")
    {
        Format = "%y/%m/%d %H:%M:%S";
    }

    Format = class'StringUtils'.static.Replace(Format, "%Y", Right(Time.Year, 4));
    Format = class'StringUtils'.static.Replace(Format, "%y", class'StringUtils'.static.Right(Time.Year, 2));
    Format = class'StringUtils'.static.Replace(Format, "%m", class'StringUtils'.static.Rjust(Time.Month, 2, "0"));
    Format = class'StringUtils'.static.Replace(Format, "%d", class'StringUtils'.static.Rjust(Time.Day, 2, "0"));
    Format = class'StringUtils'.static.Replace(Format, "%H", class'StringUtils'.static.Rjust(Time.Hour, 2, "0"));
    Format = class'StringUtils'.static.Replace(Format, "%M", class'StringUtils'.static.Rjust(Time.Minute, 2, "0"));
    Format = class'StringUtils'.static.Replace(Format, "%S", class'StringUtils'.static.Rjust(Time.Second, 2, "0"));
    Format = class'StringUtils'.static.Replace(Format, "%L", class'StringUtils'.static.Rjust(Time.TimeSeconds, 6, "0"));
    Format = class'StringUtils'.static.Replace(Format, "%T", string(class'LevelUtils'.static.ToTimestamp(Time)));

    return Format;
}

/**
 * Convert a sTime struct into a unix timestamp integer value
 * 
 * @param   struct'sTime' Time
 * @return  int
 */
static function int ToTimestamp(sTime Time)
{
    local int Year, Mon;

    Year = Time.Year;
    Mon = Time.Month-2;

    if (Mon <= 0)
    {
        Mon += 12;
        Year -= 1;
    }

    return ((((Year/4 - Year/100 + Year/400 + 367*Mon/12 + Time.Day) + Year*365 - 719499)*24 + Time.Hour)*60 +Time.Minute)*60 + Time.Second;
}

/**
 * Return current unix timestamp value
 *
 * @param   class'LevelInfo' Level
 *          Reference to the current Level instance
 * @return  int
 */
static function int Timestamp(Engine.LevelInfo Level)
{
    return class'LevelUtils'.static.ToTimestamp(class'LevelUtils'.static.GetTime(Level));
}

/**
 * Send message to a player
 *
 * @param   class'LevelInfo' Level
 * @param   class'PlayerController' PC
 * @param   string Msg
 * @param   string Color (optional)
 * @return  void
 */
static function TellPlayer(Engine.LevelInfo Level, coerce string Msg, PlayerController PC, optional string Color)
{
    Level.Game.BroadcastHandler.BroadcastText(None, PC, class'StringUtils'.static.FormatChatMessage(Msg, Color), 'Caption');
}

/**
 * Send a message to all players
 *
 * @param   class'LevelInfo' Level
 * @param   string Msg
 * @param   string Color (optional)
 * @return  void
 */
static function TellAll(Engine.LevelInfo Level, coerce string Msg, optional string Color)
{
    Level.Game.BroadcastHandler.Broadcast(None, class'StringUtils'.static.FormatChatMessage(Msg, Color), 'Caption');
}

/**
 * Send a message to all admins
 * 
 * @param   string Msg
 *          Admin Message
 * @param   class'PlayerController' Exclude (optional)
 *          A player controller that should be exluded from recieving the message
 * @param   string Color (optional)
 * @return  void
 */
static function TellAdmins(Engine.LevelInfo Level, coerce string Msg, optional PlayerController Exclude, optional string Color)
{
    local int i;
    local array<PlayerController> Admins;

    Admins = class'LevelUtils'.static.GetAdmins(Level);

    Msg = class'StringUtils'.static.FormatChatMessage(Msg, Color);
    // Send the message to every logged admin individually
    // except for the exluded player (if specified)
    for (i = 0; i < Admins.Length; i++)
    {
        if (Exclude != None && Admins[i] == Exclude)
        {
            continue;
        }
        class'LevelUtils'.static.TellPlayer(Level, Msg, Admins[i]);
    }
    // An 'AdminMsg' broadcast event is picked up
    // by BroadcastHandler module and propagated
    // further into the AMMod's webadmin console
    Level.Game.BroadcastHandler.Broadcast(None, Msg, 'AdminMsg');
}

/* vim: set ft=java: */