
Logging can only be started by means of commands in stimuli files, there are presently no GUI facilities to set up/start logging. AVR Studio currently only supports logging to file, not to the output pane.

Known issues
Stimuli files
In assignments, the operator (=, etc) must be surrounded by spaces.

The stimuli interpreter will fail if the last line of the stimuli input file is not terminated by a newline.

There is no manner to assign values to 16- or 32-bit register tuples, e.g., to assign to ADC one must assign to ADCL and ADCH separately. See example in next section.

Error reporting leaves a lot to be desired.

The timing of stimuli can be a cycle or two off compared to delay specification because stimuli files are evealuated only between CPU single-steps in the current implementation.

Sharing violation if attempting to edit a stimuli file while open.

Example stimuli file
The following example shows how ADC conversion results can be injected into the ADC data registers, and an ADC interrupt be triggered by setting the ADIF flag in ADCSRA. This example is set up for an ATmega164 but should work on most AVR devices with an ADC. The example does not show meaningful use of ADC but illustrates how stimuli files can be used.



The example also shows use of logging and break directives.



// Initial delay

#100

// Set up logging ADC and ADCSRA to file adc.log

$log ADCL

$log ADCH

$log ADCSRA

$startlog adc.log

// start of repeat loop

$repeat 100

// Assuming TCNT1 is running, use as data for ADC

ADCL = *TCNT1L

ADCH = *TCNT1H

// Set ADIF flag in ADCSRA, this will trigger ADCC interrupt

ADCSRA |= 0x10

#30

$endrep

// Stop logging (close log file)

$stoplog

// break program execution

$break 