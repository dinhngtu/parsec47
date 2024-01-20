/*
 * $Id: Logger.d,v 1.2 2004/01/01 11:26:43 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.Logger;

private:
import std.stdio;
import std.conv;

/**
 * Logger(error/info).
 */
version (Win32_release)
{

  import std.string;
  private import std.conv;
  import std.c.windows.windows;

  public class Logger
  {

    public static void info(string msg)
    {
      // Win32 exe file crashes if it writes something to stderr.
      //stderr.writeln("Info: " ~ msg);
    }

    public static void info(int n)
    {
      /*if (n >= 0)
      stderr.writeln("Info: " ~ to!string(n));
    else
    stderr.writeln("Info: -" ~ to!string(-n));*/
    }

    private static void putMessage(string msg)
    {
      MessageBoxA(null, std.string.toStringz(msg), "Error", MB_OK | MB_ICONEXCLAMATION);
    }

    public static void error(string msg)
    {
      putMessage("Error: " ~ msg);
    }

    public static void error(Throwable e)
    {
      putMessage("Error: " ~ e.toString());
    }
  }

}
else
{

  public class Logger
  {

    public static void info(string msg)
    {
      stderr.writeln("Info: " ~ msg);
    }

    public static void info(int n)
    {
      if (n >= 0)
        stderr.writeln("Info: " ~ to!string(n));
      else
        stderr.writeln("Info: -" ~ to!string(-n));
    }

    public static void error(string msg)
    {
      stderr.writeln("Error: " ~ msg);
    }

    public static void error(Throwable e)
    {
      stderr.writeln("Error: " ~ e.toString());
      if (e.next)
        error(e.next);
    }
  }

}
