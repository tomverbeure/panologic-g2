
lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.github.spinalhdl",
      scalaVersion := "2.11.6",
      version      := "1.0.0"
    )),
    libraryDependencies ++= Seq(
        "com.github.spinalhdl" % "spinalhdl-core_2.11" % "1.3.0",
        "com.github.spinalhdl" % "spinalhdl-lib_2.11"  % "1.3.0",
        "org.scalatest" % "scalatest_2.11" % "2.2.1",
        "org.yaml" % "snakeyaml" % "1.8"
    ),
    name := "panologic-g2"
  ).dependsOn(vexRiscv)
//lazy val vexRiscv = RootProject(uri("git://github.com/SpinalHDL/VexRiscv.git"))
//lazy val vexRiscv = RootProject(file("../../VexRiscv"))

//If you want a specific git commit : 
lazy val vexRiscv = RootProject(uri("git://github.com/SpinalHDL/VexRiscv.git#414d2aba54f8643ae0eade78960f02417fa910f1"))

//If the dependancy is localy on your computer : 
//lazy val vexRiscv = RootProject(file("local/path/to/the/VexRiscv/sbt/project/VexRiscv"))

fork := true
