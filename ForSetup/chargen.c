typedef enum _EColor {
	clLightGrey = 0xDF1B,
	clRed = 0xF800,
	clGreen = 0x07E0,
	clDarkBlue = 0x0154,
	clViolet = 0x5898,
//	clBlueBackgr1 = COLOR(24, 24, 28), //Цвет светло-голубого фона ! слишком синий, на солнце не видно
	clBlueFrame = COLOR(27, 29, 23),	//Цвет голубой рамки белого окна
	clBlueFrameShadow = COLOR(22, 24, 18),
	clTitle = COLOR(0, 15, 21), //Цвет надписи названия прибора и фирмы
	clTitle2 = COLOR(12, 19, 18),
	clKey0 = COLOR(27, 14, 4),  //Коричневый 23 10 2
	clKey1 = COLOR(27, 27, 0),  //Желтый     28 21 0
	clKey2 = COLOR(0, 22, 0),   //Зеленый    0  16 0
	clStatusStringGround = COLOR(0, 2, 8), //Цвет фона статус строки
//	clStatusStringInk = COLOR(3, 14, 16), //Цвет чернил статус строки (контур батарейки)
	clStatusStringInk = 0xC79F,
	clStatusStringEdge1 = COLOR(0, 12, 19), //Цвет перехода чернил в фон (уголки батарейки)
	//Цвета батарейки
	clBatGreen = COLOR(0, 16, 0),   //Зеленый
	clBatYellow = COLOR(29, 18, 0),  //Оранжевый
	clBatRed = COLOR(26, 0, 0),  //Красный
	clLtGreen = COLOR(0, 31, 0),
} EColor;

typedef enum _EAlignmentType {
	atLeft, atCenter, atRight
} EAlignmentType;

typedef struct _TBrush {
	EColor fg_color;
	EColor bg_color;
	EAlignmentType align;
	uint8_t extra_space;
} TBrush;



#define TEXT_BUFF_SIZE 0x7800 // 30 kB

typedef struct {
	uint16_t height;
	uint16_t width;
	void *data;
} TBitmapText;

static TBitmapText bitmap_struct;
static __attribute__ ((noinit)) uint8_t bitmap_buffer[TEXT_BUFF_SIZE];

uint16_t TFT_GetTextWidth(const char *text, const TFont *font) {
	uint16_t res = 0;
	int chart = 0;							// номер таблицы символов
	int char_index;							// индекс символа в массиве шрифта
	const TFontTable *table;			// таблица символов, в шрифте их много
	for (int i = 0; text[i]; i++) { // проход по тексту и вычисление ширины битмапы
		if ((uint8_t) text[i] < 9) { // символ выбора таблицы
			chart = (uint8_t) text[i] - 1;
			continue;
		}
		if (chart > 1) {
			table = font->Tables[chart];
		} else {
			if ((uint8_t) text[i] >= (uint8_t) font->Tables[1]->FirstChar) { //проверка языка
				table = font->Tables[1];
			} else {
				table = font->Tables[0];
			}
		}
		char_index = (uint8_t) text[i] - (uint8_t) table->FirstChar; // индекс символа в массиве шрифтов
		res += table->Chars[char_index][0] + Brush.extra_space;
	}
	return res;
}

/*
 * Попробовал разные варианты оптимизации
 * с прямым выводом в регистры SPI рботает медленее, буфер - хорошо
 * сделал развертку по столбцам - время не уменьшилось, на несколько тактов возможно
 * с фиксированным буфером больше жрет больше RAM, но меньше flash
 */
TBitmapText* MakeTextBitmap(const char *text, const TFont *font) {
//	TBitmapText *ret = malloc(sizeof(TBitmapText)); // выделение памяти под структуру
	TBitmapText *ret = &bitmap_struct;
	int chart = 0;							// номер таблицы символов
	int char_index;							// индекс символа в массиве шрифта
	const TFontTable *table;			// таблица символов, в шрифте их много
	ret->height = font->Height;
	ret->width = TFT_GetTextWidth(text, font);
//	uint16_t *buf = malloc(ret->height * ret->width * sizeof(uint16_t)); // выделение памяти под битмапу
	uint16_t *buf = (uint16_t*)&bitmap_buffer;
	ret->data = buf;
	chart = 0;
	for (int simv = 0; text[simv]; simv++) { // проход по символам

		if ((uint8_t) text[simv] < 9) { // символ выбора таблицы
			chart = (uint8_t) text[simv] - 1;
			continue;
		}
		if (chart > 1) {
			table = font->Tables[chart];
		} else {
			if ((uint8_t) text[simv] >= (uint8_t) font->Tables[1]->FirstChar) {	//проверка языка
				table = font->Tables[1];
			} else {
				table = font->Tables[0];
			}
		}
		char_index = (uint8_t) text[simv] - (uint8_t) table->FirstChar;	// индекс символа в массиве шрифтов

		int col_index = 1; // индекс первого столбца символа в массиве шрифта, размером bytes_per_column
		int char_width = table->Chars[char_index][0];

		for (int stolb = 0; stolb < char_width; stolb++) { // проход по столбцам
			for (int bait = 0; bait < font->BPC; bait++) { // проход по байтам столбца
				int x = table->Chars[char_index][col_index + bait]; // байт, который будет сейчас выводиться
				int bit_count =
						font->Height - bait * 8 >= 8 ? 8 : font->Height % 8; // кол-во используемых бит
				for (int bit = 0; bit < bit_count; bit++) {	// проход по битам
					*buf++ = (x & 0b1) ? Brush.fg_color : Brush.bg_color;
					x >>= 1;
				}
			}
			col_index += font->BPC;
		}
		for (int stolb = 0; stolb < Brush.extra_space; stolb++) {// дополнительное пространство между символами
			for (int stroka = 0; stroka < font->Height; stroka++) { // проход по байтам столбца
				*buf++ = Brush.bg_color;	//0xad;
			}
		}
	}
	return ret;
}