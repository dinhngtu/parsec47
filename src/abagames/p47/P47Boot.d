/*
 * $Id: P47Boot.d,v 1.6 2004/01/01 11:26:42 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.p47.P47Boot;

private:
import std.string;
private import std.conv;
import core.stdc.stdlib;
import SDL;
import abagames.util.Logger;
import abagames.util.sdl.Pad;
import abagames.util.sdl.MainLoop;
import abagames.util.sdl.Screen3D;
import abagames.util.sdl.Sound;
import abagames.p47.P47Screen;
import abagames.p47.P47GameManager;
import abagames.p47.P47PrefManager;
import abagames.p47.Ship;

/**
 * Boot the game.
 */
private:
P47Screen screen;
Pad pad;
P47GameManager gameManager;
P47PrefManager prefManager;
MainLoop mainLoop;

private void usage(string args0)
{
  Logger.error("Usage: " ~ args0 ~ " [-brightness [0-100]] [-luminous [0-100]] [-nosound] [-window] [-fullscreen] [-reverse] [-lowres] [-slowship] [-nowait]");
}

private void setHighPriority()
{
  version (Windows)
  {
    import core.sys.windows.windows;

    SetPriorityClass(GetCurrentProcess(), HIGH_PRIORITY_CLASS);
  }
}

private void parseArgs(string[] args)
{
  for (int i = 1; i < args.length; i++)
  {
    switch (args[i])
    {
    case "-brightness":
      if (i >= args.length - 1)
      {
        usage(args[0]);
        throw new Exception("Invalid options");
      }
      i++;
      float b = cast(float) to!int(args[i]) / 100;
      if (b < 0 || b > 1)
      {
        usage(args[0]);
        throw new Exception("Invalid options");
      }
      Screen3D.brightness = b;
      break;
    case "-luminous":
      if (i >= args.length - 1)
      {
        usage(args[0]);
        throw new Exception("Invalid options");
      }
      i++;
      float l = cast(float) to!int(args[i]) / 100;
      if (l < 0 || l > 1)
      {
        usage(args[0]);
        throw new Exception("Invalid options");
      }
      P47Screen.luminous = l;
      break;
    case "-nosound":
      Sound.noSound = true;
      break;
    case "-nobgm":
      Sound.noBgm = true;
      break;
    case "-volume":
      if (i >= args.length - 1)
      {
        usage(args[0]);
        throw new Exception("Invalid options");
      }
      i++;
      int v = to!int(args[i]);
      if (v < 0 || v > SDL_MIX_MAXVOLUME)
      {
        usage(args[0]);
        throw new Exception("Invalid options");
      }
      Sound.volume = v;
      break;
    case "-bgmvol":
      if (i >= args.length - 1)
      {
        usage(args[0]);
        throw new Exception("Invalid options");
      }
      i++;
      int v = to!int(args[i]);
      if (v < 0 || v > SDL_MIX_MAXVOLUME)
      {
        usage(args[0]);
        throw new Exception("Invalid options");
      }
      Sound.bgmVol = v;
      break;
    case "-window":
      Screen3D.windowMode = true;
      break;
    case "-fullscreen":
      Screen3D.windowMode = false;
      break;
    case "-nosmooth":
      Screen3D.smooth = false;
      break;
    case "-reverse":
      pad.buttonReversed = true;
      break;
    case "-lowres":
      Screen3D.lowres = true;
      break;
    case "-slowship":
      Ship.isSlow = true;
      break;
    case "-nowait":
      gameManager.nowait = true;
      break;
    case "-accframe":
      mainLoop.accframe = 1;
      break;
    case "-oldclock":
      mainLoop.precise = false;
      break;
    case "-high":
      setHighPriority();
      break;
    case "-vsync":
      if (i >= args.length - 1)
      {
        usage(args[0]);
        throw new Exception("Invalid options");
      }
      i++;
      Screen3D.vsync = to!int(args[i]);
      break;
    default:
      usage(args[0]);
      throw new Exception("Invalid options");
    }
  }
}

public int boot(string[] args)
{
  screen = new P47Screen;
  pad = new Pad;
  try
  {
    pad.openJoystick();
  }
  catch (Exception e)
  {
  }
  gameManager = new P47GameManager;
  prefManager = new P47PrefManager;
  mainLoop = new MainLoop(screen, pad, gameManager, prefManager);
  try
  {
    parseArgs(args);
  }
  catch (Exception e)
  {
    return EXIT_FAILURE;
  }
  mainLoop.loop();
  return EXIT_SUCCESS;
}

public int main(string[] args)
{
  return boot(args);
}
