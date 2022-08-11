/*
 * NS_fonts.h
 *
 *  Created on: 4 мая 2022 г.
 *      Author: CaHuTaP
 */

#ifndef NS_FONTS_H_
#define NS_FONTS_H_

typedef struct _TFontTable {
	char FirstChar;
	const unsigned char *Chars[];
} TFontTable;

typedef struct _TFont {
	unsigned char Height;
	unsigned char Width;
	unsigned char BPC; // bytes per column
	const TFontTable *Tables[];
} TFont;

#define FRANKLIN_GOTHIC_BOOK_REGULAR_28	1
#define FRANKLIN_GOTHIC_BOOK_REGULAR_19	1
#define ARIAL_REGULAR_26	1
#define COURIER_NEW_BOLD_29	1
#define TIMES_NEW_ROMAN_REGULAR_101	1
#define COURIER_NEW_BOLD_21	1

#ifdef FRANKLIN_GOTHIC_BOOK_REGULAR_28
extern const TFont Franklin_Gothic_Book_Regular_28;
#endif

#ifdef FRANKLIN_GOTHIC_BOOK_REGULAR_19
extern const TFont Franklin_Gothic_Book_Regular_19;
#endif

#ifdef ARIAL_REGULAR_26
extern const TFont Arial_Regular_26;
#endif

#ifdef COURIER_NEW_BOLD_29
extern const TFont Courier_New_Bold_29;
#endif

#ifdef COURIER_NEW_BOLD_21
extern const TFont Courier_New_Bold_21;
#endif

#ifdef TIMES_NEW_ROMAN_REGULAR_101
extern const TFont Times_New_Roman_Regular_101;
#endif

//#define Franklin_Gothic_Book_Regular_19	Courier_New_Bold_21

#endif /* NS_FONTS_H_ */
