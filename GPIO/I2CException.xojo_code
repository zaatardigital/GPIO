#tag Class
Protected Class I2CException
Inherits RuntimeException
	#tag Method, Flags = &h21
		Private Sub Constructor()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(inMethodName As String, inErrorNumber As Integer, inDeviceAddress As Integer)
		  
		  ErrorNumber = inErrorNumber
		  
		  Dim theMessage As String
		  
		  Select Case ErrorNumber
		    
		  Case kSetupFailed
		    theMessage = kSetupFailedMessage
		    
		  Case kReadingFailed
		    theMessage = kReadingFailedMessage
		    
		  Case kWritingFailed
		    theMessage = kWritingFailedMessage
		    
		  End Select
		  
		  Message = inMethodName + ": " + theMessage + " [I2C address 0x" + Hex( inDeviceAddress )  + "]"
		  
		  
		End Sub
	#tag EndMethod


	#tag Constant, Name = kReadingFailed, Type = Double, Dynamic = False, Default = \"2", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kReadingFailedMessage, Type = String, Dynamic = False, Default = \"Failed to read data.", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSetupFailed, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kSetupFailedMessage, Type = String, Dynamic = False, Default = \"Failed to get file handler.", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kWritingFailed, Type = Double, Dynamic = False, Default = \"3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kWritingFailedMessage, Type = String, Dynamic = False, Default = \"Failed to write data.", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="ErrorNumber"
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Message"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Reason"
			Group="Behavior"
			Type="Text"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
