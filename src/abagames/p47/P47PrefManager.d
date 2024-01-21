/*
 * $Id: P47PrefManager.d,v 1.2 2004/01/01 11:26:42 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.p47.P47PrefManager;

private:
import std.stdio;
import abagames.util.PrefManager;

/**
 * Save/Load the high score.
 */
public class P47PrefManager : PrefManager
{
public:
  static const int PREV_VERSION_NUM = 10;
  static const int VERSION_NUM = 20;
  static const string PREF_FILE = "p47.prf";
  static const int MODE_NUM = 2;
  static const int DIFFICULTY_NUM = 4;
  static const int REACHED_PARSEC_SLOT_NUM = 10;
  int[REACHED_PARSEC_SLOT_NUM][DIFFICULTY_NUM][MODE_NUM] hiScore;
  int[DIFFICULTY_NUM][MODE_NUM] reachedParsec;
  int selectedDifficulty, selectedParsecSlot, selectedMode;

  private void init()
  {
    for (int k = 0; k < MODE_NUM; k++)
    {
      for (int i = 0; i < DIFFICULTY_NUM; i++)
      {
        reachedParsec[k][i] = 0;
        for (int j = 0; j < REACHED_PARSEC_SLOT_NUM; j++)
        {
          hiScore[k][i][j] = 0;
        }
      }
    }
    selectedDifficulty = 1;
    selectedParsecSlot = 0;
    selectedMode = 0;
  }

  private void loadPrevVersionData(File fd)
  {
    for (int i = 0; i < DIFFICULTY_NUM; i++)
    {
      fd.rawRead((&reachedParsec[0][i])[0 .. 1]);
      for (int j = 0; j < REACHED_PARSEC_SLOT_NUM; j++)
      {
        fd.rawRead((&hiScore[0][i][j])[0 .. 1]);
      }
    }
    fd.rawRead((&selectedDifficulty)[0 .. 1]);
    fd.rawRead((&selectedParsecSlot)[0 .. 1]);
  }

  public override void load()
  {
    try
    {
      int ver;
      File fd = File(PREF_FILE);
      fd.rawRead((&ver)[0 .. 1]);
      if (ver == PREV_VERSION_NUM)
      {
        init();
        loadPrevVersionData(fd);
        return;
      }
      else if (ver != VERSION_NUM)
      {
        throw new Error("Wrong version num");
      }
      for (int k = 0; k < MODE_NUM; k++)
      {
        for (int i = 0; i < DIFFICULTY_NUM; i++)
        {
          fd.rawRead((&reachedParsec[k][i])[0 .. 1]);
          for (int j = 0; j < REACHED_PARSEC_SLOT_NUM; j++)
          {
            fd.rawRead((&hiScore[k][i][j])[0 .. 1]);
          }
        }
      }
      fd.rawRead((&selectedDifficulty)[0 .. 1]);
      fd.rawRead((&selectedParsecSlot)[0 .. 1]);
      fd.rawRead((&selectedMode)[0 .. 1]);
    }
    catch (Error e)
    {
      init();
    }
  }

  public override void save()
  {
    File fd = File(PREF_FILE, "w");
    fd.rawWrite((&VERSION_NUM)[0 .. 1]);
    for (int k = 0; k < MODE_NUM; k++)
    {
      for (int i = 0; i < DIFFICULTY_NUM; i++)
      {
        fd.rawWrite((&reachedParsec[k][i])[0 .. 1]);
        for (int j = 0; j < REACHED_PARSEC_SLOT_NUM; j++)
        {
          fd.rawWrite((&hiScore[k][i][j])[0 .. 1]);
        }
      }
    }
    fd.rawWrite((&selectedDifficulty)[0 .. 1]);
    fd.rawWrite((&selectedParsecSlot)[0 .. 1]);
    fd.rawWrite((&selectedMode)[0 .. 1]);
  }
}
