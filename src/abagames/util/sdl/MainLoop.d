/*
 * $Id: MainLoop.d,v 1.3 2004/01/01 11:26:43 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.util.sdl.MainLoop;

private:
import std.math;
import std.math.rounding;
import core.time;
import std.string;
import SDL;
import abagames.util.Logger;
import abagames.util.Rand;
import abagames.util.PrefManager;
import abagames.util.sdl.GameManager;
import abagames.util.sdl.Screen;
import abagames.util.sdl.Input;
import abagames.util.sdl.Sound;
import abagames.util.sdl.SDLInitFailedException;

/**
 * SDL main loop.
 */
public class MainLoop
{
public:
  const double INTERVAL_BASE = 16.67;
  double interval = INTERVAL_BASE;
  int accframe = 0;
  int maxSkipFrame = 5;
  bool precise = false;
  SDL_Event event;

private:
  Screen screen;
  Input input;
  GameManager gameManager;
  PrefManager prefManager;
  double clk_ms;

  public this(Screen screen, Input input,
    GameManager gameManager, PrefManager prefManager)
  {
    this.screen = screen;
    this.input = input;
    gameManager.setMainLoop(this);
    gameManager.setUIs(screen, input);
    gameManager.setPrefManager(prefManager);
    this.gameManager = gameManager;
    this.prefManager = prefManager;
    this.clk_ms = cast(double) MonoTime.currTime().ticksPerSecond() / 1000.0;
  }

  // Initialize and load preference.
  private void initFirst()
  {
    prefManager.load();
    try
    {
      Sound.init();
    }
    catch (SDLInitFailedException e)
    {
      Logger.error(e);
    }
    gameManager.init();
  }

  // Quit and save preference.
  private void quitLast()
  {
    gameManager.close();
    Sound.close();
    prefManager.save();
    screen.closeSDL();
    SDL_Quit();
  }

  private bool done;

  public void breakLoop()
  {
    done = true;
  }

  private double getSynthTicks()
  {
    return cast(double) MonoTime.currTime().ticks() / clk_ms;
  }

  private void delay(double milliseconds)
  {
    if (precise)
    {
      if (milliseconds > 1.5)
      {
        long begin = MonoTime.currTime().ticks();
        SDL_Delay(cast(int) milliseconds - 1);
        long end = MonoTime.currTime().ticks();

        double slept = cast(double)(end - begin) / clk_ms;
        milliseconds -= slept;
      }

      long begin = MonoTime.currTime().ticks();
      while ((MonoTime.currTime().ticks() - begin) / clk_ms < milliseconds)
      {
      }
    }
    else
    {
      SDL_Delay(cast(int) milliseconds);
    }
  }

  public void loop()
  {
    done = false;
    double prvTickCount = 0;
    int i;
    double nowTick;
    int frame;

    screen.initSDL();
    initFirst();
    gameManager.start();

    while (!done)
    {
      SDL_PollEvent(&event);
      input.handleEvent(&event);
      if (event.type == SDL_QUIT)
        breakLoop();
      nowTick = getSynthTicks();
      frame = cast(int)((nowTick - prvTickCount) / interval);
      if (frame <= 0)
      {
        frame = 1;
        delay(prvTickCount + interval - nowTick);
        if (accframe)
        {
          prvTickCount = getSynthTicks();
        }
        else
        {
          prvTickCount += interval;
        }
      }
      else if (frame > maxSkipFrame)
      {
        frame = maxSkipFrame;
        prvTickCount = nowTick;
      }
      else
      {
        prvTickCount += frame * interval;
      }
      for (i = 0; i < frame; i++)
      {
        gameManager.move();
      }
      screen.clear();
      gameManager.draw();
      screen.flip();
    }
    quitLast();
  }
}
