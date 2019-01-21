lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.github.spinalhdl",
      scalaVersion := "2.11.12",
      version      := "1.0.0"
    )),
    libraryDependencies ++= Seq(
//        "com.github.spinalhdl" % "spinalhdl-core_2.11" % "1.3.1",
//        "com.github.spinalhdl" % "spinalhdl-lib_2.11" % "1.3.1",
        "org.scalatest" % "scalatest_2.11" % "2.2.1",
        "org.yaml" % "snakeyaml" % "1.8"
    ),
    name := "panologic-g2"
//  ).dependsOn(vexRiscv)
  ).dependsOn(spinalHdlSim,spinalHdlCore,spinalHdlLib,vexRiscv)

//lazy val vexRiscv = RootProject(uri("git://github.com/SpinalHDL/VexRiscv.git"))
//lazy val vexRiscv = RootProject(file("../../VexRiscv"))
  lazy val vexRiscv = RootProject(uri("git://github.com/SpinalHDL/VexRiscv.git#414d2aba54f8643ae0eade78960f02417fa910f1"))

lazy val spinalHdlSim  = ProjectRef(file("../../SpinalHDL"), "sim")
lazy val spinalHdlCore = ProjectRef(file("../../SpinalHDL"), "core")
lazy val spinalHdlLib  = ProjectRef(file("../../SpinalHDL"), "lib")


fork := true
