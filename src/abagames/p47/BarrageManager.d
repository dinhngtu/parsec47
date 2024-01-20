/*
 * $Id: BarrageManager.d,v 1.2 2004/01/01 11:26:41 kenta Exp $
 *
 * Copyright 2003 Kenta Cho. All rights reserved.
 */
module abagames.p47.BarrageManager;

private:
import std.string;
import std.conv;
import std.path;
import std.file;
import bulletml;
import abagames.p47.MorphBullet;
import abagames.util.Logger;

/**
 * Barrage manager(BulletMLs' loader).
 */
public class BarrageManager {
 public:
  static enum {
    MORPH, SMALL, SMALLMOVE, SMALLSIDEMOVE,
    MIDDLE, MIDDLESUB, MIDDLEMOVE, MIDDLEBACKMOVE,
    LARGE, LARGEMOVE,
    MORPH_LOCK, SMALL_LOCK, MIDDLESUB_LOCK,
  }
  static const int BARRAGE_TYPE = 13;
  static const int BARRAGE_MAX = 64;
  BulletMLParserTinyXML* parser[BARRAGE_TYPE][BARRAGE_MAX];
  int parserNum[BARRAGE_TYPE];
 private:
  static const char[][BARRAGE_TYPE] dirName =
    ["morph", "small", "smallmove", "smallsidemove",
    "middle", "middlesub", "middlemove", "middlebackmove",
    "large", "largemove",
    "morph_lock", "small_lock", "middlesub_lock"];

  public void loadBulletMLs() {
    for (int i = 0; i< BARRAGE_TYPE; i++) {
      int j = 0;
      auto files = dirEntries(dirName[i], SpanMode.shallow);
      foreach (string fileName; files) {
	if (extension(fileName) != ".xml")
	  continue;
	Logger.info("Load BulletML: " ~ fileName);
	parser[i][j] =
	  BulletMLParserTinyXML_new(std.string.toStringz(fileName));
	BulletMLParserTinyXML_parse(parser[i][j]);
	j++;
      }
      parserNum[i] = j;
    }
  }

  public void unloadBulletMLs() {
    for (int i = 0; i< BARRAGE_TYPE; i++) {
      for (int j = 0; j < parserNum[i]; j++) {
	BulletMLParserTinyXML_delete(parser[i][j]);
      }
    }
  }
}
