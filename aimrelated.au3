func smoothmove($coords,$j,$firstms);make mouse move to the note, acceleration and alt point not working, was meant to do a circular movement(idk whats wrong in the math still testing)
   dim $currcoord[3]
   dim $diff[3]
   dim $tempdiff[3]
   dim $pixelsptms[3]
   dim $acceleration[3]
   $actgap = ($coords[$j][3][1]-$firstms) / 6
   $acttime = $firstms + $actgap
   $currcoord[1] = mousegetpos(0)
   $currcoord[2] = mousegetpos(1)
   $diff[1] = $coords[$j][1][1] - $currcoord[1]
   $diff[2] = $coords[$j][2][1] - $currcoord[2]
   if $diff[1] < 0 Then
	  $tempdiff[1] = $diff[1] * -1
   Else
      $tempdiff[1] = $diff[1]
   EndIf
   if $diff[2] < 0 Then
	  $tempdiff[2] = $diff[2] * -1
   Else
      $tempdiff[2] = $diff[2]
   EndIf
   $pixelsptms[1] = ($diff[1] / ($coords[$j][3][1]-$firstms)) * 12
   $pixelsptms[2] = ($diff[2] / ($coords[$j][3][1]-$firstms)) * 12
   $linelenght = sqrt(($tempdiff[1]^2)+($tempdiff[2]^2))
   dim $spacing[3]
   for $i = 1 to 2
   if $diff[$i] > 0 then
      $spacing[$i] = $linelenght / 10
   elseif $diff[$i] < 0 then
      $spacing[$i] = $linelenght / -10
   Else
	  $spacing[$i] = 0
	  $acceleration[$i] = 0
   EndIf
   Next
   dim $altpoint[3]
   $altpoint[1] = $currcoord[1] + ($diff[1] / 2)
   $altpoint[2] = $currcoord[2] + ($diff[2] / 2)
   dim $angle[3]
   $angle[1] = $tempdiff[1] / ($tempdiff[1] + $tempdiff[2])
   $angle[2] = $tempdiff[2] / ($tempdiff[1] + $tempdiff[2])
   $altpoint[1] += $spacing[2] * $angle[2]
   $altpoint[2] += $spacing[1] * $angle[1]
   ;if $diff[1] > $diff[2] Then
      ;$pixelsptms[2] *= ($diff[2] / $diff[1])
  ; elseif $diff[1] < $diff[2] Then
	  ;$pixelsptms[1] *= ($diff[1] / $diff[2])
   ;EndIf
   $acceleration[1] = (($altpoint[1] - $currcoord[1]) / (($coords[$j][3][1] - $firstms)/2)) * 12
   $acceleration[2] = (($altpoint[2] - $currcoord[2]) / (($coords[$j][3][1] - $firstms)/2)) * 12
   dim $ready[5]
   $ready[1] = 2
   $ready[2] = 3
   $ready[3] = 2
   $ready[4] = 3
   $firstms += 12
   $actmult = 2
   $count = 0
   while 1
	  DllCall($osumap[0], 'int', 'ReadProcessMemory', 'int', $osumap[1], 'int', $address[2], 'ptr', $bufferptr, 'int', $buffersize, 'int', '')
      $ms = DllStructGetData($buffer,1)
	  if $ms >= $coords[$j][3][1] Then return 1
	  if $ms >= $acttime Then
		 $acceleration *= $actmult
		 $acttime += $actgap
	  EndIf
	  if $acceleration[1] < 0 Then
		 if $currcoord[1] <= $altpoint[1] then
			$acceleration[1] = 0
			$ready[1] = 1
		 EndIf
	  Elseif $acceleration[1] > 0 then
	     if $currcoord[1] >= $altpoint[1] then
			$acceleration[1] = 0
			$ready[1] = 1
		 EndIf
	  EndIf
	  if $acceleration[2] < 0 Then
		 if $currcoord[2] <= $altpoint[2] then
			$acceleration[2] = 0
			$ready[2] = 1
		 EndIf
	  Elseif $acceleration[2] > 0 then
	     if $currcoord[2] >= $altpoint[2] then
			$acceleration[2] = 0
			$ready[2] = 2
		 EndIf
	  EndIf
	  if $ready[1] = $ready[2] Then
		 $count += 1
		 if $count = 2 Then return -1
		 $acceleration[1] *= -1
		 $acceleration[2] *= -1
		 $altpoint[1] = $coords[$j][1][1]
		 $altpoint[2] = $coords[$j][2][1]
		 $actmult = 0.5
	     $ready[1] = 2
		 $ready[2] = 3
	  EndIf
	  if $pixelsptms[1] < 0 Then
		 if $currcoord[1] <= $coords[$j][1][1] Then
			$currcoord[1] = $coords[$j][1][1]
			$ready[3] = 1
			$pixelsptms[1] = 0
		 EndIf
	  Else
		 if $currcoord[1] >= $coords[$j][1][1] Then
			$currcoord[1] = $coords[$j][1][1]
			$ready[3] = 1
			$pixelsptms[1] = 0
		 EndIf
	  EndIf
	  if $pixelsptms[2] < 0 then
		 if $currcoord[2] <= $coords[$j][2][1] Then
			$currcoord[2] = $coords[$j][2][1]
			$ready[4] = 1
			$pixelsptms[2] = 0
		 EndIf
	  Else
		 if $currcoord[2] >= $coords[$j][2][1] Then
			$currcoord[2] = $coords[$j][2][1]
			$ready[4] = 1
			$pixelsptms[2] = 0
		 EndIf
	  EndIf
	  if $ready[3] = $ready[4] Then return -1
	  if $ms >= $firstms Then
		 $currcoord[1] += $pixelsptms[1] ;+ $acceleration[1]
		 $currcoord[2] += $pixelsptms[2] ;+ $acceleration[2]
		 $firstms += 12
		 mousemove($currcoord[1],$currcoord[2],0)
	  EndIf
   WEnd
EndFunc


func calcbpm($diff,$red,$green);calculates the final bpm in every point
   dim $tempbpm[$red[0][0] + $green[0][0] + 1][4]
   $sliderbasemult = 1
   $j = 1
   $k = 1
   if $green[0][0] = 0 then
	  redim $green[2][3]
	  $green[1][1] = 1000000
   EndIf
   for $i = 1 to $red[0][0] + $green[0][0]
   If $red[$j][1] > $green[$k][1] Then
	  $tempbpm[$i][1] = $green[$k][1] - 10
	  $tempbpm[$i][2] = $red[$j-1][2] / $green[$k][2]
	  $tempbpm[$i][3] = 2
	  $k += 1
   ElseIf $green[$k][1] >= $red[$j][1] Then
	  $tempbpm[$i][1] = $red[$j][1] - 10
	  $tempbpm[$i][2] = $red[$j][2] * $sliderbasemult
	  $tempbpm[$i][3] = 1
	  $j += 1
   Else
	  error(15)
   EndIf
   if $j > $red[0][0] then
	  for $l = $i+1 to $red[0][0] + $green[0][0]
		 $tempbpm[$l][1] = $green[$k][1] - 10
		 $tempbpm[$l][2] = $red[$j-1][2] / $green[$k][2]
	     $tempbpm[$l][3] = 2
		 $k += 1
	  Next
	  exitloop
   ElseIf $k > $green[0][0] Then
	  for $l = $i+1 to $green[0][0] + $red[0][0]
		 $tempbpm[$l][1] = $red[$j][1] - 10
	     $tempbpm[$l][2] = $red[$j][2] * $sliderbasemult
	     $tempbpm[$l][3] = 1
	     $j += 1
	  Next
	  exitloop
   EndIf
   Next
   $m = 2
   dim $finalbpm[$m][4]
   $finalbpm[1][1] =  $tempbpm[1][1]
   $finalbpm[1][2] = $tempbpm[1][2]
   $finalbpm[1][3] = $tempbpm[1][3]
   for $i = 1 to $green[0][0] + $red[0][0] - 1
	  if $tempbpm[$i][2] = $tempbpm[$i+1][2] then

	  Else
		 redim $finalbpm[$m+1][4]
		 $finalbpm[$m][1] = $tempbpm[$i+1][1]
		 $finalbpm[$m][2] = $tempbpm[$i+1][2]
		 $finalbpm[$m][3] = $tempbpm[$i+1][3]
		 $m += 1
	  EndIf
   Next
   $finalbpm[0][0] = $m-1
   ;_ArrayDisplay($finalbpm)
   return $finalbpm
EndFunc

func getspinners($notes)
   $k = 1
   dim $spinners[1][5]
   for $i = 1 to $notes[0][0][0]
	  if $notes[$i][0][1] = "spinner" Then
		 redim $spinners[$k+1][5]
		 $spinners[$k][1] = $notes[$i][1][1]
		 $spinners[$k][2] = $notes[$i][2][1]
		 $spinners[$k][3] = $notes[$i][3][1]
		 $spinners[$k][4] = $notes[$i][6][1]
		 $k += 1
	  EndIf
   Next
   $spinners[0][0] = ubound($spinners)-1
   return $spinners
EndFunc

func getextendedcoords($notes)
   local $ext[$notes[0][0][0]+1][3][2]
   local $basecoord[3]
   $curhigh = 2
   $j = 1
   for $i = 1 to $notes[0][0][0]
	  if $notes[$i][0][1] = "slider" Then
		 $tmoves = floor($notes[$i][3][3] / 10)
		 if $tmoves >= $curhigh then
			redim $ext[$notes[0][0][0]+1][3][$tmoves+1]
			$curhigh = $tmoves+1
		 EndIf
		 if $notes[$i][6][1] = "B" then
			$nmoves = 1 / $tmoves
			local $basepoints[$notes[$i][1][0]][3]
			for $j = 0 to $notes[$i][1][0]-1
			   ;msgbox(0,"",$i & @CRLF & $notes[$i][1][0] & @CRLF & $j)
			   $basepoints[$j][1] = $notes[$i][1][$j+1]
			   $basepoints[$j][2] = $notes[$i][2][$j+1]
			Next
			$n = 0
			for $j = 0 to 1-$nmoves step $nmoves
			   $n += 1
			   $ext[$i][1][$n] = getBcurvepoint($basepoints,$notes[$i][1][0]-1,$j)
			Next
	     elseif $notes[$i][6][1] = "P" Then
			$nmoves = 1 / $tmoves
			local $basepoints[$notes[$i][1][0]+1][3]
			for $j = 1 to $notes[$i][1][0]
			   $basepoints[$j][1] = $notes[$i][1][$j]
			   $basepoints[$j][2] = $notes[$i][2][$j]
			Next
			$n = 0
			for $j = 0 to 1-$nmoves step $nmoves
			   $n += 1
			   $ext[$i][1][$n] = getPcircle($basepoints,$j)
			Next
		 ;if $notes[$i][6][1] = "L" Then
		 Else
			$nmoves = floor($tmoves / $notes[$i][7][1])
			$moves = floor($nmoves / ($notes[$i][1][0] - 1))
			$in = 0
			$basecoord[1] = $notes[$i][1][1]
			$basecoord[2] = $notes[$i][2][1]
			for $k = 2 to $notes[$i][1][0]
			   for $j = $in + 1 to $moves + $in
				  ;msgbox(0,"",$j & @CRLF & $tmoves & @CRLF & $nmoves & @CRLF & $moves & @CRLF & ubound($ext,1) & @CRLF & $i & @CRLF & ubound($ext,3))
				  $ext[$i][1][$j] = $basecoord[1] + ((($notes[$i][1][$k] - $basecoord[1]) / $moves) *($j-$in))
				  $ext[$i][2][$j] = $basecoord[2] + ((($notes[$i][2][$k] - $basecoord[2]) / $moves) *($j-$in))
			   Next
			   $ext[$i][1][$moves+$in] = $notes[$i][1][$k]
			   $ext[$i][2][$moves+$in] = $notes[$i][2][$k]
			   $basecoord[1] = $notes[$i][1][$k]
			   $basecoord[2] = $notes[$i][2][$k]
			   $in += $moves
			Next
			$in = 0
			if $notes[$i][7][1] > 1 Then
			   for $r = 1 to $notes[$i][7][1]
			      for $k = 2 to $notes[$i][1][0]
			         for $j = ($nmoves*$r) + $in + 1 to ($nmoves*$r) + $moves + $in
				        $ext[$i][1][$j] = $ext[$i][1][$j-(($j-($nmoves*$r))*2)]
				        $ext[$i][2][$j] = $ext[$i][2][$j-(($j-($nmoves*$r))*2)]
			         Next
			         $in += $moves
			      Next
			   Next
			EndIf
			$ext[$i][1][0] = $tmoves
			$ext[$i][2][0] = $tmoves
		 EndIf
	  EndIf
   Next
   $ext[0][0][0] = $notes[0][0][0]
   return $ext
EndFunc

func altslidermove($j,$extended,$firstms)
   $firstms += 10
   for $i = 1 to $extended[$j][1][0]
	  while 1
	     DllCall($osumap[0], 'int', 'ReadProcessMemory', 'int', $osumap[1], 'int', $address[2], 'ptr', $bufferptr, 'int', $buffersize, 'int', '')
	     $ms = DllStructGetData($buffer,1)
		 if $ms >= $firstms Then ExitLoop
	  WEnd
	  mousemove($extended[$j][1][$i],$extended[$j][2][$i],0)
	  consolewrite($i & @CRLF)
	  $firstms += 10
   Next
EndFunc

func slidermove($i,$notes,$firstms)
   $firstms += 10
   $moves = floor(($notes[$i][3][3] / $notes[$i][7][1]) / 10)
   $nmoves = (1 / $moves)
   if $notes[$i][6][1] = "B" or $notes[$i][6][1] = "L" or $notes[$i][6][1] = "C" then
	  local $basepoints[$notes[$i][1][0]][3]
	  for $j = 0 to $notes[$i][1][0]-1
		 $basepoints[$j][1] = $notes[$i][1][$j+1]
		 $basepoints[$j][2] = $notes[$i][2][$j+1]
	  Next
	  $start = 0
	  $end = 1
	  $sadd = $nmoves
	  for $r = 1 to $notes[$i][7][1]
		 $t = $start
	     while 1
		    DllCall($osumap[0], 'int', 'ReadProcessMemory', 'int', $osumap[1], 'int', $address[2], 'ptr', $bufferptr, 'int', $buffersize, 'int', '')
	        if DllStructGetData($buffer,1) >= $firstms then
		       $t += $sadd
		      ; $tomove = getBcurvepoint($basepoints,$notes[$i][1][0]-1,$t)
			   consolewrite("bt: " & $t & @CRLF)
		       $tomove = _Bezier_GetPoint($basepoints,$t)
			   ;msgbox(0,"",$t & @CRLF & $tomove[1] & @CRLF & $tomove[2])
		       mousemove($tomove[1],$tomove[2],0)
			   $firstms += 10
		    EndIf
			if $end = 1 Then
		       if $t >= $end then ExitLoop
			Else
			   if $t <= $end then ExitLoop
			EndIf
		 WEnd
		 $scont = $start
	     $start = $end
	     $end = $scont
	     $sadd *= -1
	  Next
   Elseif $notes[$i][6][1] = "P" Then
      local $basepoints[$notes[$i][1][0]+1][3]
      for $j = 1 to $notes[$i][1][0]
		 $basepoints[$j][1] = $notes[$i][1][$j]
		 $basepoints[$j][2] = $notes[$i][2][$j]
	  Next
	  $tomove = getPcircle($basepoints,$moves)
	  $start = 0
	  $end = $moves
	  $sadd = 1
	  for $r = 1 to $notes[$i][7][1] step 1
	     for $j = $start+$sadd to $end step $sadd
	        while 1
		       DllCall($osumap[0], 'int', 'ReadProcessMemory', 'int', $osumap[1], 'int', $address[2], 'ptr', $bufferptr, 'int', $buffersize, 'int', '')
		       if DllStructGetData($buffer,1) >= $firstms then
			      mousemove($tomove[$j][1],$tomove[$j][2],0)
			      $firstms += 10
			      ExitLoop
		       EndIf
	        WEnd
	     Next
	     $scont = $start
	     $start = $end
	     $end = $scont
	     $sadd *= -1
	  Next
   EndIf
EndFunc

Func _Bezier_GetPoint($B, $t)
    Local $n = UBound($B) - 1
    For $k = 1 To $n
        For $i = 0 To $n - $k
            $B[$i][1] = (1 - $t) * $B[$i][1] + $t * $B[$i + 1][1]
            $B[$i][2] = (1 - $t) * $B[$i][2] + $t * $B[$i + 1][2]
        Next
    Next
    Local $ret[3]
    $ret[1] = $B[0][1]
    $ret[2] = $B[0][2]
    Return $ret
EndFunc

func getBcurvepoint($basepoints,$n,$t)
   $x = 0
   $y = 0
   for $i = 0 to $n
	  $x += bin($i,$n)*(1-$t)^($n-$i)*($t^$i)*$basepoints[$i][1]
	  $y += bin($i,$n)*(1-$t)^($n-$i)*($t^$i)*$basepoints[$i][2]
   Next
   dim $a[3]
   $a[1] = $x
   $a[2] = $y
   return $a
EndFunc

func bin($x,$y)
   if $x = 0 then return 1
   if $x = $y then return 1
   if $x > 1 Then
      for $i = $x-1 to 1 step -1
         $x *= $i
      Next
   EndIf
   if $y > 1 Then
      for $i = $y-1 to 1 step -1
	     $y *= $i
      Next
   EndIf
   $z = $y - $x
   if $z > 1 Then
	  for $i = $z to 1 step -1
		 $z *= $i
	  Next
   EndIf
   $x *= $z
   $z = $y / $x
   return $z
EndFunc

func getabsolutecoords($x,$type)
   if $type = 0 Then
	  $y = ($osuCoordX + ($x * $scale) + $marginLeft)
   elseif $type = 1 Then
	  $y = ($osuCoordY + ($x * $scale) + $marginTop)
   EndIf
   return $y
EndFunc

func getPcircle($basepoints,$tmoves)
   $rconvert = 57.295779513082320
   $convert = 0.0174532925199433
   local $angle[4]
   local $diffx[4]
   local $diffy[4]
   local $line[4]
   $diffx[1] = positive($basepoints[1][1] - $basepoints[2][1])
   $diffy[1] = positive($basepoints[1][2] - $basepoints[2][2])
   $diffx[2] = positive($basepoints[2][1] - $basepoints[3][1])
   $diffy[2] = positive($basepoints[2][2] - $basepoints[3][2])
   $diffx[3] = positive($basepoints[1][1] - $basepoints[3][1])
   $diffy[3] = positive($basepoints[1][2] - $basepoints[3][2])
   for $i = 1 to 3
      if $diffx[$i] = 0 Then
	     $line[$i] = $diffy[$i]
      ElseIf $diffy = 0 then
	     $line[$i] = $diffx[$i]
      Else
	     $line[$i] = sqrt(($diffx[$i]^2)+($diffy[$i]^2))
      EndIf
   Next
   $diameter = (2*$line[1]*$line[2]*$line[3]) / (sqrt(($line[1]+$line[2]+$line[3])*(($line[1]*-1)+$line[2]+$line[3])*($line[1]+($line[2]*-1)+$line[3])*($line[1]+$line[2]+($line[3]*-1))))
   $radius = $diameter/2
   $D = 2*(($basepoints[1][1]*($basepoints[2][2]-$basepoints[3][2]))+($basepoints[2][1]*($basepoints[3][2]-$basepoints[1][2]))+($basepoints[3][1]*($basepoints[1][2]-$basepoints[2][2])))
   $Xcenter = (((($basepoints[1][1]^2)+($basepoints[1][2]^2))*($basepoints[2][2]-$basepoints[3][2])) + ((($basepoints[2][1]^2)+($basepoints[2][2]^2))*($basepoints[3][2]-$basepoints[1][2])) + ((($basepoints[3][1]^2)+$basepoints[3][2]^2)*($basepoints[1][2]-$basepoints[2][2]))) / $D
   $Ycenter = (((($basepoints[1][1]^2)+($basepoints[1][2]^2))*($basepoints[3][1]-$basepoints[2][1])) + ((($basepoints[2][1]^2)+($basepoints[2][2]^2))*($basepoints[1][1]-$basepoints[3][1])) + ((($basepoints[3][1]^2)+$basepoints[3][2]^2)*($basepoints[2][1]-$basepoints[1][1]))) / $D
   for $i = 1 to 3
      $WidthLine = $basepoints[$i][1]-$Xcenter
      $HeightLine = $Ycenter-$basepoints[$i][2]
      $atan = abs(round(ATan($HeightLine/$WidthLine)*$rconvert,0))
	  $Angle[$i] = fixangle($basepoints[$i][1]-$Xcenter,$basepoints[$i][2]-$Ycenter,$atan)
   Next
   local $finalcoords[$tmoves+1][3]
   for $j = 1 to $tmoves
	  $t = $j * (1 / $tmoves)
	  consolewrite("t: " & $t & @CRLF)
   if positive($Angle[2] - $Angle[1]) < 180 and $Angle[2] - $Angle[1] > 0 Then
	  if $Angle[3] < $Angle[1] Then
	     $i = $Angle[1] + ((360-(positive($Angle[3] - $Angle[1]))) * $t)
	  Else
		 $i = $Angle[1] + ((positive($Angle[3] - $Angle[1])) * $t)
	  EndIf
   Elseif positive($Angle[2] - $Angle[1]) < 180 and $Angle[2] - $Angle[1] < 0 Then
      if $Angle[3] > $Angle[1] Then
	     $i = $Angle[1] - ((360-(positive($Angle[3] - $Angle[1]))) * $t)
	  Else
		 $i = $Angle[1] - ((positive($Angle[3] - $Angle[1])) * $t)
	  EndIf
   elseif positive($Angle[2] - $Angle[1]) > 180 and $Angle[2] - $Angle[1] > 0 Then
	  if $Angle[3] > $Angle[1] Then
	     $i = $Angle[1] - ((360-(positive($Angle[3] - $Angle[1]))) * $t)
	  Else
		 $i = $Angle[1] - ((positive($Angle[3] - $Angle[1])) * $t)
	  EndIf
   ElseIf positive($Angle[2] - $Angle[1]) > 180 and $Angle[2] - $Angle[1] < 0 Then
	  if $Angle[3] < $Angle[1] Then
	     $i = $Angle[1] + ((360-(positive($Angle[3] - $Angle[1]))) * $t)
	  Else
		 $i = $Angle[1] + ((positive($Angle[3] - $Angle[1])) * $t)
	  EndIf
   EndIf
   if $i <= 0 then $i += 360
   if $i > 360 then $i -= 360
   $cos = cos($i * $convert) * $radius
   $sin = sin($i * $convert) * $radius
   $finalcoords[$j][1] = $Xcenter + $cos
   $finalcoords[$j][2] = $Ycenter + $sin
   Next
   return $finalcoords
EndFunc

func getbezierlenght($basepoints)
   local $currcoord[3]
   local $diff[3]
   $blenght = 0
   $currcoord[1] = $basepoints[0][1]
   $currcoord[2] = $basepoints[0][2]
   for $t = 0.001 to 1 step 0.001
      $z = _Bezier_GetPoint($basepoints,$t)
	  $diff[1] = positive($currcoord[1] - $z[1])
	  $diff[2] = positive($currcoord[2] - $z[2])
	  $blenght += sqrt(($diff[1]^2)+($diff[2]^2))
	  $currcoord[1] = $z[1]
	  $currcoord[2] = $z[2]
   Next
   msgbox(0,"e",$blenght)
   return $blenght
EndFunc