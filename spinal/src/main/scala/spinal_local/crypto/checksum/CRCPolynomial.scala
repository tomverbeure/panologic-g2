/*                                                                           *\
**        _____ ____  _____   _____    __                                    **
**       / ___// __ \/  _/ | / /   |  / /   Crypto                           **
**       \__ \/ /_/ // //  |/ / /| | / /    (c) Dolu, All rights reserved    **
**      ___/ / ____// // /|  / ___ |/ /___                                   **
**     /____/_/   /___/_/ |_/_/  |_/_____/                                   **
**                                                                           **
**      This library is free software; you can redistribute it and/or        **
**    modify it under the terms of the GNU Lesser General Public             **
**    License as published by the Free Software Foundation; either           **
**    version 3.0 of the License, or (at your option) any later version.     **
**                                                                           **
**      This library is distributed in the hope that it will be useful,      **
**    but WITHOUT ANY WARRANTY; without even the implied warranty of         **
**    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU      **
**    Lesser General Public License for more details.                        **
**                                                                           **
**      You should have received a copy of the GNU Lesser General Public     **
**    License along with this library.                                       **
\*                                                                           */
package spinal_local.crypto.checksum


import spinal_local.crypto._
import spinal_local.crypto.PolynomialGF2


/**
  * Class used to define the configuration of a CRC
  * @param polynomial      : CRC polynomial
  * @param initValue       : init value of the CRC
  * @param inputReflected  : if true the input is reflected  (inverse)
  * @param outputReflected : if true the output is reflected (inverse)
  * @param finalXor        : this value is xor with the ouptut result
  */
class CRCPolynomial(
   val polynomial      : PolynomialGF2,
   val initValue       : BigInt,
   val inputReflected  : Boolean,
   val outputReflected : Boolean,
   val finalXor        : BigInt
)


/**
  * Define all CRC 32
  */
object CRC32 {
  def Standard  = new CRCPolynomial(polynomial = p"32'x04C11DB7", initValue = BigInt("FFFFFFFF", 16), inputReflected = true,  outputReflected = true,  finalXor = BigInt("FFFFFFFF", 16))
  def XFER      = new CRCPolynomial(polynomial = p"32'x000000AF", initValue = BigInt("00000000", 16), inputReflected = false, outputReflected = false, finalXor = BigInt("00000000", 16))
}


/**
  * Define all CRC 16
  */
object CRC16 {
  def XModem    = new CRCPolynomial(polynomial = p"16'x1021", initValue = BigInt("0000", 16), inputReflected = false, outputReflected = false, finalXor = BigInt("0000", 16))
}


/**
  * Define all CRC 8
  */
object CRC8 {
  def Standard  = new CRCPolynomial(polynomial = p"8'x07", initValue = BigInt("00", 16), inputReflected = false, outputReflected = false, finalXor = BigInt("00", 16))
  def DARC      = new CRCPolynomial(polynomial = p"8'x39", initValue = BigInt("00", 16), inputReflected = true,  outputReflected = true,  finalXor = BigInt("00", 16))
}

