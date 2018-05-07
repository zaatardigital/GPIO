#tag Class
Protected Class PCF8574
	#tag Method, Flags = &h0
		Function Channel(inChannelNumber As Integer) As Boolean
		  //-- Return the state of a channel as a boolean
		  //- inNumber: the channel's number (0-7)
		  
		  // -- Pre conditions
		  
		  // The channel must be from 0 to 7
		  If inChannelNumber < 0 Or inChannelNumber > 7 Then
		    Dim theException As New OutOfBoundsException
		    theException.Message = CurrentMethodName + ": inChannelNumber must be from 0 to 7 but was " + Str( inChannelNumber )
		    Raise theException
		    
		  End If
		  
		  // -- The channel number is valid
		  
		  // Read the channels register from the device
		  Dim theRegister As Integer = GPIO.I2CRead( pFileHandler )
		  
		  // Check for read error
		  If theRegister < 0 Then
		    // There was an error while reading
		    Raise New I2CException( CurrentMethodName, I2CException.kReadingFailed, mI2CAddress )
		    
		  End If
		  
		  // Apply a bit mask (AND) to isolate the channel's bit and make it a Boolean
		  Dim theChannelState As Boolean = CType( Bitwise.BitAnd( theRegister, Pow( 2, inChannelNumber ) ), Boolean )
		  Return theChannelState
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Channel(inChannelNumber As Integer, Assigns inValue As Boolean)
		  //-- Set the state of a channel
		  //- inChannelNumber: The number of the channel (0-7). It can't be an input channel
		  //- inValue: The channel state to set 
		  
		  // -- Pre conditions
		  
		  // The channel must be from 0 to 7
		  If inChannelNumber < 0 Or inChannelNumber > 7 Then
		    Dim theException As New OutOfBoundsException
		    theException.Message = CurrentMethodName + ": inChannelNumber must be from 0 to 7 but was " + Str( inChannelNumber )
		    Raise theException
		    
		  End If
		  
		  // The channel must be an output
		  If ChannelMode( inChannelNumber ) <> PCF8574.ChannelModes.Output Then
		    // Well, it isn't.
		    Dim theException As New UnsupportedOperationException
		    theException.Message = CurrentMethodName + ": The channel #" + Str( inChannelNumber ) + " is not an output"
		    Raise theException
		    
		  End If
		  
		  // -- The channel number is valid
		  
		  // Read the channels register from the device
		  Dim theRegister As Integer = GPIO.I2CRead( pFileHandler )
		  
		  // Check for read error
		  If theRegister < 0 Then
		    // There was an error while reading
		    Raise New I2CException( CurrentMethodName, I2CException.kReadingFailed, mI2CAddress )
		    
		  End If
		  
		  // Calculate the mask for the channel bit
		  Dim theChannelBitsMask As Integer = Pow( 2, 1 )
		  
		  // Sets the channel's new (or not new) bit value and preserve the others
		  If inValue Then
		    // Set the channel's bit (OR)
		    theRegister = theRegister Or theChannelBitsMask
		    
		  Else
		    // Clear the channel's bit (AND with inversed mask)
		    theRegister = theRegister And Not theChannelBitsMask
		    
		  End If
		  
		  // Apply the input mask (OR)
		  theRegister = theRegister Or pInputsMask
		  
		  // Write the updated register back to the device
		  Dim theWriteError As Integer = GPIO.I2CWrite( pFileHandler, theRegister )
		  
		  // Check for error on writing
		  If theWriteError < 0 Then
		    Raise New GPIO.I2CException( CurrentMethodName, I2CException.kWritingFailed, mI2CAddress )
		    
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ChannelMode(inChannelNumber As Integer) As PCF8574.ChannelModes
		  //-- Return the mode of a channel
		  //- inChannelNumber: The number of the channel to test
		  
		  // -- Precondition --
		  
		  // The channel must be from 0 to 7
		  If inChannelNumber < 0 Or inChannelNumber > 7 Then
		    Dim theException As New OutOfBoundsException
		    theException.Message = CurrentMethodName + ": inChannelNumber must be from 0 to 7  but was " + Str( inChannelNumber )
		    Raise theException
		    
		  End If
		  
		  // Isolate the channel's from the input mask and make it a boolean
		  Dim theInputBit As Boolean = Ctype( Bitwise.BitAnd( pInputsMask, Pow( 2, inChannelNumber ) ), Boolean )
		  
		  // If the input bit is true, then it's an input, otherwise it's an output
		  Return If( theInputBit, PCF8574.ChannelModes.Input, PCF8574.ChannelModes.Output )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ChannelMode(inChannelNumber As Integer, Assigns inMode As PCF8574.ChannelModes)
		  //-- Set a channel as an output or an input
		  //- inChannel: The number of the channel to be set
		  //- inMode: The state of the channel
		  
		  // -- Precondition --
		  
		  // The channel must be from 0 to 7
		  If inChannelNumber < 0 Or inChannelNumber > 7 Then
		    Dim theException As New OutOfBoundsException
		    theException.Message = CurrentMethodName + ": inChannelNumber must be from 0 to 7 but was " + Str( inChannelNumber )
		    Raise theException
		    
		  End If
		  
		  // -- The channel number is valid
		  
		  // Process the data
		  Select Case inMode
		    
		  Case PCF8574.ChannelModes.Output
		    // Set the channel as an output
		    // Note: No need to change its current state
		    Dim theUpdateMask As Integer = 255 - Pow( 2, inChannelNumber )
		    
		    // Update the input mask (i.e. sets the channel bit to 0)
		    pInputsMask = pInputsMask And theUpdateMask
		    
		  Case PCF8574.ChannelModes.Input
		    // Set the channel as an input
		    // Note: We'll have to set its state as high (boolean True)
		    
		    // Read the channels register from the device
		    Dim theRegister As Integer = GPIO.I2CRead( pFileHandler )
		    
		    // Check for read error
		    If theRegister < 0 Then
		      // There was an error while reading
		      Raise New I2CException( CurrentMethodName, I2CException.kReadingFailed, mI2CAddress )
		      
		    End If
		    
		    // The update mask will force inChannel's bit to True while not touching the other ones
		    Dim theUpdateMask As Integer = Pow( 2, inChannelNumber )
		    
		    // Update the input mask
		    pInputsMask = pInputsMask Or theUpdateMask
		    
		    // Apply the new input mask to the register to set the channel high
		    theRegister = theRegister Or pInputsMask
		    
		    // Write back the channels register
		    Dim theWriteError As Integer = GPIO.I2CWrite( pFileHandler, theRegister )
		    
		    // Check for write error
		    If theWriteError < 0 Then
		      // There was an error while writing
		      Raise New I2CException( CurrentMethodName, I2CException.kWritingFailed, mI2CAddress )
		      
		    End If
		    
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Function Channels() As Boolean()
		  //-- Return an array with all the channel bits in a single read
		  
		  // Read the device state
		  Dim theRegister As Integer = GPIO.I2CRead( pFileHandler )
		  
		  // Check for read error
		  If theRegister < 0 Then
		    // There was an error while reading
		    Raise New I2CException( CurrentMethodName, I2CException.kReadingFailed, mI2CAddress )
		    
		  End If
		  
		  // Build the channels bits array
		  Dim theBits( 7 ) As Boolean
		  
		  For i As Integer = 0 To 7
		    // Set the i-th bit value
		    Dim theBitMask As Integer = Pow( 2, i )
		    theBits( i ) = CType( theRegister And theBitMask, Boolean )
		    
		  Next
		  
		  // Return the bits array
		  Return theBits
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Channels(inChannels() As Integer, inBits() As Boolean)
		  //-- Sets multiple channels at once
		  //- inChannels(): An array with each channel's number to be set. This array must at least contain one but no more than eight elements.
		  //  It can't contain any duplicate channel number nor the number of an input channel
		  //- inBits(): An array of the state to set to channels to. The number of elements must be the same as the inChannels() parameter or just one element.
		  //  Each channel in  will be set accordingly to its corresponding item from inStates (i.e. with the same index )
		  //  or to the same inStates() element if there is only one
		  
		  // Cache the arrays upper bounds
		  Dim theChannelsUbound As Integer = inChannels.Ubound
		  Dim theBitsUbound As Integer = inBits.Ubound
		  
		  // -- Pre Conditions --
		  
		  // There can't be no channels or more than 8 channels
		  If theChannelsUbound < 0 Or theChannelsUbound > 7 Then // Arrays are zero-based
		    Dim theException As New OutOfBoundsException
		    theException.Message = CurrentMethodName + "inChannels() must contains from 1 to 8 item (was " + Str( theChannelsUbound + 1 ) + ")."
		    Raise theException
		    
		  Elseif theChannelsUbound <> theBitsUbound And theBitsUbound <> 0 Then
		    // the arrays don't have the same count of items and inBits() is not a single element
		    Dim theException As New UnsupportedOperationException
		    theException.Message = CurrentMethodName + ": inBits() must have the same number of elements than inChannels() or just a single one." _
		    + " inChannels() has " + Str( theChannelsUbound + 1 ) + " element(s) and inBits() has " + Str( theBitsUbound + 1 )
		    Raise theException
		    
		  End If
		  
		  // -- Let's process the data
		  
		  // Define the mask and the updated channel bit(s) numerical value(s)
		  Dim theClearedBitsMask As Integer
		  Dim theChannelsNumValue As Integer
		  
		  For i As Integer = 0 To theChannelsUbound
		    // Get the channel number
		    Dim theChannelNumber As Integer = inChannels( i )
		    
		    // -- Check the channel number validity
		    
		    // The channel number must be from 0 to 7
		    If theChannelNumber < 0 Or theChannelNumber > 7 Then
		      // The channel number is out of bounds
		      Dim theException As New OutOfBoundsException
		      theException.Message = CurrentMethodName + "The channel number for item #" + Str( i ) + " must be from 0 to 7 but was " + Str( theChannelNumber )
		      Raise theException
		      
		    End If
		    
		    // Compute the bit's numerical value
		    Dim theBitNumValue As Integer = Pow( 2, theChannelNumber )
		    
		    // -- Check for channel number validity
		    
		    // It can't be an input
		    If CType( pInputsMask And theBitNumValue, Boolean ) Then
		      // This channel is an input
		      Dim theException As New UnsupportedOperationException
		      theException.Message = CurrentMethodName + ": The channel #" + Str( theChannelNumber ) + " can't be set because it's defined as an input."
		      Raise theException
		      
		    End If
		    
		    // If there is a duplicate channel, its bit in the cleared bits mask is already set
		    If Ctype( theClearedBitsMask And theBitNumValue, Boolean ) Then
		      // This is a duplicate
		      Dim theException As New UnsupportedOperationException
		      theException.Message = CurrentMethodName + ": The channel number " + Str( theChannelNumber ) + " for item # " + Str( i ) + " has already been set."
		      Raise theException
		      
		    End If
		    
		    // update the register mask by setting the channel's bit
		    theClearedBitsMask = theClearedBitsMask Or theBitNumValue
		    
		    #Pragma warning "It needs a bit of clarifying below"
		    
		    // Set the new state of the channel's bit
		    If inBits( If( theBitsUbound = 0, 0, i ) ) Then
		      theChannelsNumValue = theChannelsNumValue Or theBitNumValue
		      
		    End If
		    
		  Next
		  
		  // -- Update the device
		  
		  // Read the current register value
		  Dim theRegister As Integer = GPIO.I2CRead( pFileHandler )
		  
		  // Check for read error
		  If theRegister < 0 Then
		    // There was an error while reading
		    Raise New GPIO.I2CException( CurrentMethodName, I2CException.kReadingFailed, mI2CAddress )
		    
		  End If
		  
		  // Clear the bits of the updated channel(s) and keep the others (AND) then update its/their value(s) (OR)
		  // Note: the operator precedence is as follows: Not, And Or. So no need of parenthesis
		  theRegister = theRegister And Not theClearedBitsMask Or theChannelsNumValue
		  
		  // Apply the input mask (OR)
		  theRegister = theRegister Or pInputsMask
		  
		  // Write the updated register back to the device
		  Dim theWriteError As Integer = GPIO.I2CWrite( pFileHandler, theRegister )
		  
		  // Check for error on writing
		  If theWriteError < 0 Then
		    Raise New GPIO.I2CException( CurrentMethodName, I2CException.kWritingFailed, mI2CAddress )
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Constructor()
		  //-- Disabled constructor
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Sub Constructor(inDeviceAddress As Integer)
		  //-- Setup a PCF8574 device instance
		  //- inDeviceAddress: the 7-bit I2C adresss of the device (without R/W bit)
		  // The builtin default address of the PCF8574 is &h20 and &h30 for the PCF8574A.
		  // The default address can be modified by using the A0, A1 and A2 pin.
		  // See the datasheet for PCF8574/PCF8574A for more details.
		  
		  // Get the filehandler for the device given its address
		  Dim theFileHandler As Integer = GPIO.I2CSetup( inDeviceAddress )
		  
		  // Check for error
		  If theFileHandler < 0 Then 
		    // We couldn't get a file handler
		    Raise New GPIO.I2CException( CurrentMethodName, GPIO.I2CException.kSetupFailed, inDeviceAddress )
		    
		  End If
		  
		  // Store the parameters
		  mI2CAddress = inDeviceAddress
		  pFileHandler = theFileHandler
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Destructor()
		  //-- This instance is about to be history, let's do some cleaning
		  
		  // This will stop the interrupt observer if there is one
		  If pInterruptObserver <> Nil Then StopInterruptObserver
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InterruptObserverRun(refObserver As Thread)
		  //-- This is the delegate for the interrupt observer thread's Run() event
		  //- refObserver: a reference to the thread handling the delegate.
		  // It checks periodically the state of the interrupt pin
		  
		  Do
		    // Do we have an interrupt (i.e. interrupt pin is low)
		    If GPIO.DigitalRead( pInterruptPin ) = GPIO.LOW Then
		      // Yes, get the register's bits and raise the Interrupt event
		      // Note: The I2C read operation will clear the interrupt output of the device
		      RaiseEvent Interrupt( Channels )
		      
		    End If
		    
		    // Let's go for a nap
		    refObserver.Sleep( pInterruptObserverSleepTime, pInterruptObserverWakeEarly )
		    
		  Loop
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StartInterruptObserver(inInterruptPin As Integer, inSleepTime As Integer = 100, inWakeEarly As Boolean = False)
		  //-- Start the interrupt observer thread
		  //- inInterruptPin: The number of the pin where the INT channel of the PCF is connected
		  // in respect of the GPIO.Setup method you used.
		  //- inSleepTime: The time interval between 2 'observations' in msecs. (100 by default)
		  //- inWakeEarly: If True it allows the oberver thread to wake up early if there are no other threads able to execute.
		  
		  // Set the pin as input 
		  GPIO.PinMode( pInterruptPin, GPIO.INPUT )
		  
		  // Create a thread to listen to the interrupt pin.
		  Dim theObserver As New Thread
		  AddHandler theObserver.Run, AddressOf Self.InterruptObserverRun
		  
		  // Store a reference to the observer and the pin number
		  pInterruptObserver = theObserver
		  pInterruptPin = inInterruptPin
		  
		  // and the thread running parameters
		  pInterruptObserverSleepTime = inSleepTime
		  pInterruptObserverWakeEarly = inWakeEarly
		  
		  // Start the observer
		  theObserver.Run
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StopInterruptObserver()
		  //-- Stop the interrup observing thread
		  // Raised an UnsupportedOperationException if none is running
		  
		  // Kill the interrupt observer if needed
		  If pInterruptObserver = Nil Then
		    Dim theException As UnsupportedOperationException
		    theException.Message = CurrentMethodName + ": There is no interrupt observer to stop."
		    Raise theException
		    
		  End if
		  
		  // Kill the thread and clear its reference
		  pInterruptObserver.Kill
		  pInterruptObserver = Nil
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToggleChannel(inChannelNumber As Integer)
		  //-- Toogle the state of a single channel
		  //- inChannel: The number of the channel to be toggled.
		  
		  // -- Pre Conditions --
		  
		  // The channel number must be from 0 to 7
		  If inChannelNumber < 0 Or inChannelNumber > 7 Then
		    // The channel number is out of bounds
		    Dim theException As New OutOfBoundsException
		    theException.Message = CurrentMethodName + "The channel nunmber must be from 0 to 7 but was " + Str( inChannelNumber )
		    Raise theException
		    
		  End If
		  
		  // Is it an output?
		  If ChannelMode( inChannelNumber ) <> PCF8574.ChannelModes.Output Then
		    // No it isn't...
		    Dim theException As New UnsupportedOperationException
		    theException.Message = CurrentMethodName + ": The channel #" + Str( inChannelNumber ) + " is not an output."
		    Raise theException
		    
		  End If
		  
		  // Set up the toggleMask
		  Dim theToggleMask As Integer = Pow( 2, inChannelNumber )
		  
		  // Read the channel register from the device
		  Dim theRegister As Integer = GPIO.I2CRead( pFileHandler )
		  
		  // Check for read error
		  If theRegister < 0 Then
		    // There was an error while reading
		    Raise New I2CException( CurrentMethodName, I2CException.kReadingFailed, mI2CAddress )
		    
		  End If
		  
		  // Apply the toggle mask (XOR) and the input mask (OR) to keep the input channel(s) high
		  // Note: Xor and Or have the same operator precedence
		  theRegister = theRegister Xor theToggleMask Or pInputsMask 
		  
		  // Write the updated register back to the device
		  Dim theWriteError As Integer = GPIO.I2CWrite( pFileHandler, theRegister  )
		  
		  // Check for error on writing
		  If theWriteError < 0 Then
		    Raise New GPIO.I2CException( CurrentMethodName, I2CException.kWritingFailed, mI2CAddress )
		    
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ToggleChannels(inChannels() As Integer)
		  //-- Toogles the state of the channel number(s) in th array
		  //- inChannel: An array of channel numbers to toggle
		  
		  // Cache the upperbound of the channel numbers array
		  Dim theUbound As Integer = inChannels.Ubound
		  
		  // -- Pre Conditions --
		  
		  // There can't be no channels or more than 8 channels
		  // Note: Arrays are zero-based
		  If theUbound < 0 Or theUbound > 7 Then
		    Dim theException As New UnsupportedOperationException
		    theException.Message = CurrentMethodName + ": There must be at least one and no more than 8 channels to toggle but there was " + Str( theUbound + 1 )
		    Raise theException
		    
		  End If
		  
		  // -- Build the toggle mask
		  
		  Dim theToggleMask As Integer
		  
		  For i As Integer = 0 To theUbound
		    // Get the channel number
		    Dim theChannel As Integer = inChannels( i )
		    
		    // -- Check the channel number validity
		    
		    // The channel number must be from 0 to 7
		    If theChannel < 0 Or theChannel > 7 Then
		      // The channel number is out of bounds
		      Dim theException As New OutOfBoundsException
		      theException.Message = CurrentMethodName + "The channel number for item #" + Str( i ) + " must be from 0 to 7 but was " + Str( theChannel )
		      Raise theException
		      
		    End If
		    
		    // Is it an output?
		    If ChannelMode( theChannel ) <> PCF8574.ChannelModes.Output Then
		      // No it isn't
		      Dim theException As New UnsupportedOperationException
		      theException.Message = CurrentMethodName + ": The channel #" + Str( theChannel ) + " is not an output."
		      Raise theException
		      
		    End If
		    
		    // Compute the bit's numerical value
		    Dim theBitNumValue As Integer = Pow( 2, theChannel )
		    
		    // -- Check for duplicate channel number
		    
		    // If there is a duplicate channel, its bit in the mask is already set
		    If ( theToggleMask And theBitNumValue ) > 0 Then
		      // This is a duplicate
		      Dim theException As New UnsupportedOperationException
		      theException.Message = CurrentMethodName + ": The channel #" + Str( theChannel ) + " for item #" + Str( i ) + " has already been set"
		      Raise theException
		      
		    End If
		    
		    // Set the channel's bit in the toggle mask
		    theToggleMask = theToggleMask + theBitNumValue
		    
		  Next
		  
		  // -- Set up the device
		  
		  // Read the channel register
		  Dim theRegister As Integer = GPIO.I2CRead( pFileHandler )
		  
		  // Check for read error
		  If theRegister < 0 Then
		    // There was an error while reading
		    Raise New I2CException( CurrentMethodName, I2CException.kReadingFailed, mI2CAddress )
		    
		  End If
		  
		  // Apply the toggle mask (XOR) and the input mask (OR) to keep the input channel(s) high
		  // Note: AND has a higher operator precedence than XOR, hence the parenthesis so the toggling is applied before the input mask
		  theRegister = theRegister Xor theToggleMask Or pInputsMask 
		  
		  Dim theWriteError As Integer = GPIO.I2CWrite( pFileHandler, theRegister)
		  
		  // Check for error on writing
		  If theWriteError < 0 Then
		    Raise New GPIO.I2CException( CurrentMethodName, I2CException.kWritingFailed, mI2CAddress )
		    
		  End If
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event Interrupt(inChannelBits() As Boolean)
	#tag EndHook


	#tag Note, Name = About
		The GPIO.PCF8574 class is an abstraction of the I2C remote 8-bit I/O expander PCF8574.
		It provides methods to read and set the 8 channels provided by this integrated circuit without bothering about the I2C exchange.
		It also assists you with the managing of the input or output states of the PCF8574, which can be tricky to handle properly.
		Finally, GPIO.PCF8574 class provides you with a mechanism to handle interupts with an easy to setup and use observer thread.
		
		** The CHANNEL_ON and CHANNEL_OFF Constants
		
		By design the active state of a channel as an output is when it's logical state is LOW and inactive when it's HIGH.
		To match this behavior and for a better readability, the Boolean constant CHANNEL_ON is False and CHANNEL_OFF is True.
		
		** About interrupts
		
		WiringPi provides a mechanism to handle interrupts with the wiringPiISR() function. Unfortunately, it uses preemptive thread,
		which is not safe to use with Xojo. the CPIO.PCF8574 class uses a Xojo native thread to periodically observe the state of the pin
		where the INT pin of the PCF8574 is connected to the Raspbery Pi.
		
		** More documentation
		
		Each method is documented at the top of its code, explaining what it does and what the parameters are for.
	#tag EndNote

	#tag Note, Name = The PCF8574 chip
		** Remote 8-bit I/O expander for I2C-bus with interrupt
		
		The PCF8574/74A provides 8 remote I/O channels with interrupt driven by the two-wire bidirectional I2C-bus.
		Each channel is an independant quasi-bidirectional port that can be assigned as a digital input or output.
		It works with a Vcc between 2.5V and 6V with a maximum current of 80ma.
		
		Datasheets:
		 - Texas Instruments:
		         http://www.ti.com/lit/ds/symlink/pcf8574.pdf
		
		 - NXP:
		         https://www.nxp.com/docs/en/data-sheet/PCF8574_PCF8574A.pdf
		
		
	#tag EndNote


	#tag ComputedProperty, Flags = &h0, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		#tag Getter
			Get
			  //-- Return the I2C device address
			  
			  Return mI2CAddress
			End Get
		#tag EndGetter
		I2CAddress As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Private mI2CAddress As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pFileHandler As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pInputsMask As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pInterruptObserver As Thread
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pInterruptObserverSleepTime As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pInterruptObserverWakeEarly As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private pInterruptPin As Integer
	#tag EndProperty


	#tag Constant, Name = kChannel_OFF, Type = Boolean, Dynamic = False, Default = \"True", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kChannel_ON, Type = Boolean, Dynamic = False, Default = \"False", Scope = Public
	#tag EndConstant


	#tag Enum, Name = ChannelModes, Type = Integer, Flags = &h0
		Input
		Output
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="I2CAddress"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
