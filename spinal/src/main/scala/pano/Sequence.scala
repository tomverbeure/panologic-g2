
package pano

import spinal.core._

// Eventually, this needs to become that whole thing with FSMs etc. 

class Sequence(seq: Bool){

    def |->(that: Bool): Bool = {
        val result = Bool

        result := !seq || that

        result
    }

    def |=>(that: Bool): Bool = {
        val result = Bool

        result := !RegNext(seq) || that

        result
    }

}

package object lib {
    implicit def sequence(that: Bool)= new Sequence(that)
}

