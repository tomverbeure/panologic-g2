/*                                                                           *\
**        _____ ____  _____   _____    __                                    **
**       / ___// __ \/  _/ | / /   |  / /   Crypto                           **
**       \__ \/ /_/ // //  |/ / /| | / /    (c) Dolu, All rights reserved    **
**      ___/ / ____// // /|  / ___ |/ /___                                   **
**     /____/_/   /___/_/ |_/_/  |_/_____/  MIT Licence                      **
**                                                                           **
** Permission is hereby granted, free of charge, to any person obtaining a   **
** copy of this software and associated documentation files (the "Software"),**
** to deal in the Software without restriction, including without limitation **
** the rights to use, copy, modify, merge, publish, distribute, sublicense,  **
** and/or sell copies of the Software, and to permit persons to whom the     **
** Software is furnished to do so, subject to the following conditions:      **
**                                                                           **
** The above copyright notice and this permission notice shall be included   **
** in all copies or substantial portions of the Software.                    **
**                                                                           **
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS   **
** OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                **
** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.    **
** IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY      **
** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT **
** OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR  **
** THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                **
\*                                                                           */
package spinal_local.crypto

import scala.collection.mutable.ListBuffer


/**
  * Polynomial in Galois Field 2
  */
class PolynomialGF2(val coefficient: List[Int]) {

  def ==(that: PolynomialGF2): Boolean = this.coefficient.sorted == that.coefficient.sorted
  def !=(that: PolynomialGF2): Boolean = !(this == that)

  def order: Int = coefficient.max


  override def toString: String = {
    (for(coef <- coefficient) yield coef match{
      case 0 => "1"
      case 1 => "x"
      case _ => s"x^$coef"
    }).mkString(" + ")
  }

  /**
    * Return a list of boolean representing the polynomial
    */
  def toBooleanList(): List[Boolean] = {

    val listBuffer = ListBuffer[Boolean]()

    for(i <- 0 to coefficient.max){
      listBuffer.append(coefficient.contains(i))
    }

    return listBuffer.toList.reverse
  }
}


/**
  * Transform a BigInt value into a hexadecimal string
  */
object BigIntToHexString {
  def apply(value: BigInt): String = s"0x${value.toByteArray.map(b => f"${b}%02X").mkString("")}"
}


/**
  * Change endianness on Array[Byte]
  */
object Endianness {
  def apply(input: Array[Byte]): Array[Byte] = {
    assert(input.length % 4 == 0, s"Endianess input is not a multiple of 4 (current length ${input.length}) ")
    return input.grouped(4).flatMap(_.reverse.toList).toArray
  }
}

/**
  * Cast a Byte Array
  */
object CastByteArray {
  def apply(input: Array[Byte], castSize: Int): Array[Byte] = {
    if (input.length == castSize) {
      input
    } else if (input.length > castSize) {
      input.takeRight(castSize)
    } else {
      Array.fill[Byte](castSize - input.length)(0x00) ++ input
    }
  }
}




