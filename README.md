linear-actuator
===============

Code and model files for open source linear actuator.

For full access to BOM, instructions and the academic paper on the testing of
the open source syringe pump see the
[page on appropedia](http://www.appropedia.org/Open-source_syringe_pump).

To compile the scad file, you'll need the files from our
[libraries](https://github.com/mtu-most/most-scad-libraries).

We no longer recommend using the Raspberry Pi in the way that is described in
the paper; instead, an Arduino with a stepper motor driver works much better;
Franklin can for example be used to control it.

However, pump-server should still work.  To use it, make sure you copy (or
link) rpc.js from the python-websocketd repository to the html directory.
