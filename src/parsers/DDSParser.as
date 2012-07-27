/**
 *    纯as3的dds解析器
 */
package parsers
{
	import away3d.loaders.parsers.ParserBase;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

	import flash.net.URLLoaderDataFormat;

	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import utils.Log;

	public class DDSParser extends ParserBase
	{
		public static function supportsType(extension:String):Boolean
		{
			return extension.toLowerCase() == 'dds';
		}

		public static function supportsData(data:*):Boolean
		{
			return true;
		}

		private static const DXT1:int = 1;
		private static const DXT5:int = 2;
		private var _dxtFormat:int;

		private var _output:ByteArray;


		private var _sig1:int;
		private var _sig2:int;
		private var _sig3:int;
		private var _sig4:int;
		private var _width:int;
		private var _height:int;
		private var _depth:int;
		private var _flags:int;
		private var _fourCC:int;

		public function get width():int
		{
			return _width;
		}

		public function get height():int
		{
			return _height;
		}


		public function DDSParser()
		{
			super(URLLoaderDataFormat.BINARY);
		}

		protected override function proceedParsing() : Boolean
		{
			if (decompressDDS(_data) == null)
			{
				// TODO: Log the texture name.
				Log.e('Texture loading error.');
				parsingFailure = true;
				return PARSING_DONE;
			}
			var bmpData:BitmapData = new BitmapData(_width, _height, true, 0);
			bmpData.setPixels(bmpData.rect, _output);
			var texture:BitmapTexture = new BitmapTexture(bmpData);
			finalizeAsset(texture);
			return PARSING_DONE;
		}

		public function decompressDDS(input:ByteArray):ByteArray
		{
				input.position = 0;
				input.endian = Endian.LITTLE_ENDIAN;
				_output = new ByteArray;
				_output.endian = Endian.LITTLE_ENDIAN;

				// 读DDS头
				readHeader(input);

				if (!checkHeader())
					return null;

				_output.length = _width * _height * 4;

				// 读像素
				if (_dxtFormat == DXT1)
					decompressDXT1(input);
				else if (_dxtFormat == DXT5)
					decompressDXT5(input);
				else
				{
					return null;
				}

			_output.position = 0;
			return _output;
		}

		private function readHeader(input:ByteArray):void
		{
			// read signature
			_sig1 = input.readUnsignedByte();
			_sig2 = input.readUnsignedByte();
			_sig3 = input.readUnsignedByte();
			_sig4 = input.readUnsignedByte();

			input.readUnsignedInt();		// size1
			input.readUnsignedInt();		// flags1
			_height = input.readUnsignedInt();		// height
			_width = input.readUnsignedInt();		// width
			input.readUnsignedInt();		// LinearSize
			_depth = input.readUnsignedInt();		// depth
			input.readUnsignedInt();		// mipmap count
			input.readUnsignedInt();		// alpha bit depth

			for (var i:int = 0; i < 10; i++)
				input.readUnsignedInt();	// no used

			input.readUnsignedInt();		// size2
			_flags = input.readUnsignedInt();		// flags2
			_fourCC = input.readUnsignedInt();		// FourCC
			input.readUnsignedInt();		// RGBBitCount
			input.readUnsignedInt();		// RBitMask
			input.readUnsignedInt();		// GBitMask
			input.readUnsignedInt();		// BBitMask
			input.readUnsignedInt();		// RGB Alpha Bit Mask
			input.readUnsignedInt();		// dds Caps1
			input.readUnsignedInt();		// dds Caps2
			input.readUnsignedInt();		// dds Caps3
			input.readUnsignedInt();		// dds Caps4
			input.readUnsignedInt();		// Texture Stage

			if (_depth == 0)
				_depth = 1;
		}

		private function checkHeader():Boolean
		{
			// check signature
			if (_sig1 != 68 || _sig2 != 68 || _sig3 != 83)
				return false;

			// check width and height
			if (_width == 0 || _height == 0)
				return false;

			if (_flags != 4)
				return false;

			if (_fourCC == 0x31545844)    // DXT1
				_dxtFormat = 1;
			else if (_fourCC == 0x35545844)        // DXT5
				_dxtFormat = 2;
			else
			{
				return false;
			}

			return true;
		}

		private function decompressDXT1(input:ByteArray):void
		{
			var bitmask:int;
			var colours0:Vector.<int> = new Vector.<int>(4, true);
			var colours1:Vector.<int> = new Vector.<int>(4, true);
			var colours2:Vector.<int> = new Vector.<int>(4, true);
			var colours3:Vector.<int> = new Vector.<int>(4, true);

			colours0[3] = 0xff;
			colours1[3] = 0xff;
			colours2[3] = 0xff;

			for (var z:int = 0; z < _depth; z++)
			{
				for (var y:int = 0; y < _height; y += 4)
				{
					for (var x:int = 0; x < _width; x += 4)
					{
						var color_0:int = input.readUnsignedShort();
						var color_1:int = input.readUnsignedShort();
						bitmask = input.readUnsignedInt();


						DxtcReadColor(color_0, colours0);
						DxtcReadColor(color_1, colours1);

						if (color_0 > color_1)
						{
							colours2[2] = (2 * colours0[2] + colours1[2] + 1) / 3;
							colours2[1] = (2 * colours0[1] + colours1[1] + 1) / 3;
							colours2[0] = (2 * colours0[0] + colours1[0] + 1) / 3;

							colours3[2] = (colours0[2] + 2 * colours1[2] + 1) / 3;
							colours3[1] = (colours0[1] + 2 * colours1[1] + 1) / 3;
							colours3[0] = (colours0[0] + 2 * colours1[0] + 1) / 3;
							colours3[3] = 0xff;
						}
						else
						{
							colours2[2] = (colours0[2] + colours1[2]) / 2;
							colours2[1] = (colours0[1] + colours1[1]) / 2;
							colours2[0] = (colours0[0] + colours1[0]) / 2;

							colours3[2] = (colours0[2] + 2 * colours1[2] + 1) / 3;
							colours3[1] = (colours0[1] + 2 * colours1[1] + 1) / 3;
							colours3[0] = (colours0[0] + 2 * colours1[0] + 1) / 3;
							colours3[3] = 0x00;
						}

						var k:int = 0;
						for (var j:int = 0; j < 4; j++)
						{
							for (var i:int = 0; i < 4; i++)
							{
								var shift:int = (k * 2);
								var xx:int = (bitmask & (0x03 << (k * 2)));
								var xxx:int = xx >> shift;
								var shiftMask:int;
								if (shift > 0)
								{
									shiftMask = (0x80000000 >> (shift - 1));
									shiftMask = ~shiftMask;
								}
								else
								{
									shiftMask = 0xffffffff
								}
								var Select:int = xxx & shiftMask;
//								var Select:int = (bitmask & (0x03<<k*2)) >> k*2;

								var colours:Vector.<int>;
								switch (Select)
								{
									case 0:
										colours = colours0;
										break;
									case 1:
										colours = colours1;
										break;
									case 2:
										colours = colours2;
										break;
									case 3:
										colours = colours3;
										break;
									default:
										throw new Error("DDS Parser2 error");
										break;
								}

								if (((x + i) < _width) && ((y + j) < _height))
								{
									var Offset:int = z * (_height * _width * 4) + (y + j) * (_width * 4) + (x + i) * 4;
									_output.position = Offset;
									_output.writeByte(colours[2]);		// r
									_output.writeByte(colours[1]);		// g
									_output.writeByte(colours[0]);		// b
									_output.writeByte(colours[3]);		// a
//									Debug.bltrace(y+" "+x+" "+j+" "+i+" "+"Select="+Select+" "+colours[2]+" "+colours[1]+" "+colours[0]);

								}
								k++
							} // for i
						} // for j
					} // for x
				} // for y
			}// for z

		}

		private function DxtcReadColor(cClr:int, colours:Vector.<int>):void
		{
			// r5 g6 b5
			var b:int = cClr & 0x1f;
			var g:int = (cClr & 0x7e0) >> 5;
			var r:int = (cClr & 0xf800) >> 11;

			var r1:int = r << 3 | r >> 2;
			var g1:int = g << 2 | g >> 3;
			var b1:int = b << 3 | r >> 2;

			colours[0] = r1;
			colours[1] = g1;
			colours[2] = b1;

		}


		private function decompressDXT5(input:ByteArray):void
		{
			var alphas:Vector.<int> = new Vector.<int>(8, true);
			var alphamask:Vector.<int> = new Vector.<int>(6, true);
			var colours0:Vector.<int> = new Vector.<int>(4, true);
			var colours1:Vector.<int> = new Vector.<int>(4, true);
			var colours2:Vector.<int> = new Vector.<int>(4, true);
			var colours3:Vector.<int> = new Vector.<int>(4, true);

			for (var z:int = 0; z < _depth; z++)
			{
				for (var y:int = 0; y < _height; y += 4)
				{
					for (var x:int = 0; x < _width; x += 4)
					{
						if (y >= _height || x >= _width)
							break;

						alphas[0] = input.readUnsignedByte();
						alphas[1] = input.readUnsignedByte();
						alphamask[0] = input.readUnsignedByte();
						alphamask[1] = input.readUnsignedByte();
						alphamask[2] = input.readUnsignedByte();
						alphamask[3] = input.readUnsignedByte();
						alphamask[4] = input.readUnsignedByte();
						alphamask[5] = input.readUnsignedByte();

						var clr:int = input.readUnsignedInt();
						DxtcReadColors(clr, colours0, colours1);
						var bitmask:uint = input.readUnsignedInt();


						// parse color
						colours2[2] = (2 * colours0[2] + colours1[2] + 1) / 3;
						colours2[1] = (2 * colours0[1] + colours1[1] + 1) / 3;
						colours2[0] = (2 * colours0[0] + colours1[0] + 1) / 3;

						colours3[2] = (colours0[2] + 2 * colours1[2] + 1) / 3;
						colours3[1] = (colours0[1] + 2 * colours1[1] + 1) / 3;
						colours3[0] = (colours0[0] + 2 * colours1[0] + 1) / 3;

						var k:int = 0;
						var j:int = 0;
						var i:int = 0;
						for (j = 0; j < 4; j++)
						{
							for (i = 0; i < 4; i++)
							{
								var shift:int = (k * 2);
								var xx:int = (bitmask & (0x03 << (k * 2)));
								var xxx:int = xx >> shift;
								var shiftMask:int;
								if (shift > 0)
								{
									shiftMask = (0x80000000 >> (shift - 1));
									shiftMask = ~shiftMask;
								}
								else
								{
									shiftMask = 0xffffffff
								}
								var Select:int = xxx & shiftMask;

//								var Select:uint = (bitmask & (0x03 << (k*2))) >> (k*2);


								var colours:Vector.<int>;
								switch (Select)
								{
									case 0:
										colours = colours0;
										break;
									case 1:
										colours = colours1;
										break;
									case 2:
										colours = colours2;
										break;
									case 3:
										colours = colours3;
										break;
									default:
										throw new Error("DDS Parser2 error");
										break;
								}

								if (((x + i) < _width) && ((y + j) < _height))
								{
									var Offset:int = z * (_height * _width * 4) + (y + j) * (_width * 4) + (x + i) * 4;
									_output.position = Offset;
									_output.writeByte(colours[2]);		// r
									_output.writeByte(colours[1]);		// g
									_output.writeByte(colours[0]);		// b

//									Debug.bltrace(x+" "+y+" "+i+" "+j+" "+"Select="+Select+" "+colours[2]+" "+colours[1]+" "+colours[0]);
								}

								k++;
							}
						}

						// parse alpha
						if (alphas[0] > alphas[1])
						{
							alphas[2] = (6 * alphas[0] + 1 * alphas[1] + 3) / 7;
							alphas[3] = (5 * alphas[0] + 2 * alphas[1] + 3) / 7;
							alphas[4] = (4 * alphas[0] + 3 * alphas[1] + 3) / 7;
							alphas[5] = (3 * alphas[0] + 4 * alphas[1] + 3) / 7;
							alphas[6] = (2 * alphas[0] + 5 * alphas[1] + 3) / 7;
							alphas[7] = (1 * alphas[0] + 6 * alphas[1] + 3) / 7;
						}
						else
						{
							alphas[2] = (4 * alphas[0] + 1 * alphas[1] + 2) / 5;
							alphas[3] = (3 * alphas[0] + 2 * alphas[1] + 2) / 5;
							alphas[4] = (2 * alphas[0] + 3 * alphas[1] + 2) / 5;
							alphas[5] = (1 * alphas[0] + 4 * alphas[1] + 2) / 5;
							alphas[6] = 0x00;
							alphas[7] = 0xff;
						}

						var bits:int = (alphamask[0]) | (alphamask[1] << 8) | (alphamask[2] << 16);
						for (j = 0; j < 2; j++)
						{
							for (i = 0; i < 4; i++)
							{
								if (((x + i) < _width) && ((y + j) < _height))
								{
									Offset = z * (_height * _width * 4) + (y + j) * (_width * 4) + (x + i) * 4 + 3;
									_output.position = Offset;
									_output.writeByte(alphas[bits & 0x07]);
//									Debug.bltrace(x+" "+y+" "+i+" "+j+" "+(bits & 0x07));
								}
								bits >>= 3;
							}
						}
						bits = (alphamask[3]) | (alphamask[4] << 8) | (alphamask[5] << 16);
						for (j = 2; j < 4; j++)
						{
							for (i = 0; i < 4; i++)
							{
								if (((x + i) < _width) && ((y + j) < _height))
								{
									Offset = z * (_height * _width * 4) + (y + j) * (_width * 4) + (x + i) * 4 + 3;
									_output.position = Offset;
									_output.writeByte(alphas[bits & 0x07]);
//									Debug.bltrace(x+" "+y+" "+i+" "+j+" "+(bits & 0x07));
								}
								bits >>= 3;
							}
						}

					}
				}
			}
		}

		private function DxtcReadColors(clr:int, colours0:Vector.<int>, colours1:Vector.<int>):void
		{
			var byte0:int = clr & 0xff;
			var byte1:int = (clr & 0xff00) >> 8;
			var byte2:int = (clr & 0xff0000) >> 16;
			var byte3:int = (clr & 0xff000000) >> 24;

			var r0:int;
			var g0:int;
			var b0:int;
			var r1:int;
			var g1:int;
			var b1:int;

			b0 = byte0 & 0x1f;
			g0 = ((byte0 & 0xe0) >> 5) | ((byte1 & 0x7) << 3);
			r0 = (byte1 & 0xf8) >> 3;

			b1 = byte2 & 0x1f;
			g1 = ((byte2 & 0xe0) >> 5) | ((byte3 & 0x7) << 3);
			r1 = (byte3 & 0xf8) >> 3;

			colours0[0] = r0 << 3 | r0 >> 2;
			colours0[1] = g0 << 2 | g0 >> 3;
			colours0[2] = b0 << 3 | b0 >> 2;

			colours1[0] = r1 << 3 | r1 >> 2;
			colours1[1] = g1 << 2 | g1 >> 3;
			colours1[2] = b1 << 3 | b1 >> 2;
		}


	}
}