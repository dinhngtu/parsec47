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
import core.atomic;
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
  const double INTERVAL_MS = 16.6667;
  long interval;
  long interval_base;
  int accframe = 0;
  int maxSkipFrame = 5;
  bool precise = true;
  bool fdb = false;
  SDL_Event event;
  int hasEvent = 0;

private:
  Screen screen;
  Input input;
  GameManager gameManager;
  PrefManager prefManager;
  long clk_ms;

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
    this.clk_ms = MonoTime.currTime().ticksPerSecond() / 1000;
    this.interval = this.interval_base = MonoTime.currTime().ticksPerSecond() / 60;
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

  private void delay(long count)
  {
    long milliseconds = count / clk_ms;
    if (precise)
    {
      long begin = MonoTime.currTime().ticks();
      if (milliseconds > 1)
        SDL_Delay(cast(int) milliseconds - 1);
      while (MonoTime.currTime().ticks() - begin < count)
        core.atomic.pause();
    }
    else
    {
      SDL_Delay(cast(int) milliseconds);
    }
  }

  public void slow(double factor)
  {
    interval += cast(long)((factor * interval_base - interval) * 0.1);
  }

  public void unslow()
  {
    interval += cast(long)((interval_base - interval) * 0.08);
  }

  public void resetSlow()
  {
    interval = interval_base;
  }

  public void loop()
  {
    done = false;
    long prvTickCount = 0;
    int i;
    long nowTick;
    long frame;
    long toWait;

    screen.initSDL();
    initFirst();
    gameManager.start();

    while (!done)
    {
      hasEvent = SDL_PollEvent(&event);
      if (hasEvent)
      {
        hasEvent = true;
        if (event.type == SDL_QUIT)
          breakLoop();
      }
      input.poll();
      nowTick = MonoTime.currTime().ticks();
      frame = (nowTick - prvTickCount) / interval;
      toWait = 0;
      if (frame <= 0)
      {
        frame = 1;
        toWait = prvTickCount + interval - nowTick;
        if (fdb)
        {
          toWait /= 2;
          delay(toWait);
        }
        else
        {
          delay(toWait);
        }
        if (accframe)
        {
          prvTickCount = MonoTime.currTime().ticks();
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
      if (fdb && toWait > 0)
      {
        screen.clear();
        gameManager.draw();
        screen.flip();
        delay(toWait);
      }
      screen.clear();
      gameManager.draw();
      screen.flip();
    }
    quitLast();
  }
}
