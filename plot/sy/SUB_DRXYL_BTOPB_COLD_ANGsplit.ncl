;------------------------------------------------------------------------
load  "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load  "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load  "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load  "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load  "$NCARG_ROOT/lib/UDF.ncl"
;------------------------------------------------------------------------
;strs = (/sat,"_",instrument,"_","OBC","_","HOT_ANG_","CONFIG",".","ncl"/)
;config_file = str_concat(strs)
;print(config_file)

;loadscript(config_file)

  begin    
    err = NhlGetErrorObjectId() 
    setvalues err 
      "errLevel" : "Fatal" ; only report Fatal errors 
    end setvalues  
 
;; get the number of days
    bg_ymd=BG_YMD
    ed_ymd=ED_YMD  
    bg_yer=bg_ymd/10000
    ed_yer=ed_ymd/10000
    bg_mon=mod(bg_ymd/100, 100)
    ed_mon=mod(ed_ymd/100, 100)
;    print(bg_yer+"  "+ed_yer+" "+bg_mon+" "+ed_mon)
    ndys = (/31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31/)
    nday = 0
    do iyer = bg_yer, ed_yer
      if ( isleapyear(iyer) ) then
        ndys(1) = 29
      else
        ndys(1) = 28
      end if
 
      imn1  = 1
      imn2  = 12
      if ( iyer .eq. bg_yer ) then
        imn1  = bg_mon
      end if
      if ( iyer .eq. ed_yer ) then
        imn2  = ed_mon
      end if

      do imon = imn1, imn2
        nday  = nday + ndys(imon - 1) 
      end do
    end do
   print (nday)
    
    ntim    = 4
    timlab  = new((/1, nday*ntim/), integer, -9999)
    
    irec    = 0
    do iyer = bg_yer, ed_yer
      if ( isleapyear(iyer) ) then
        ndys(1) = 29
      else
        ndys(1) = 28
      end if
      
      imn1  = 1
      imn2  = 12
      if ( iyer .eq. bg_yer ) then
        imn1  = bg_mon
      end if

      if ( iyer .eq. ed_yer ) then
        imn2  = ed_mon
      end if
            
      do imon = imn1, imn2
        do iday = 1, ndys(imon - 1)
          do ihor = 0, ntim - 1
            timlab(0, irec) = iyer*1000000 + imon*10000 + iday*100 + ihor*6
            irec =irec + 1
          end do
        end do
      end do
      
    end do      
     
    f_var1  = addfile(file_in, "r")
    
    cold_ang1 = f_var1->cold_ang1 
    cold_ang1 = cold_ang1/10
    
    cold_ang2 = f_var1->cold_ang2
    cold_ang2 = cold_ang2/10
    
    din14    = f_var1->time
    timlab2 = din14(:, 0)
    timlab2 = din14(:, 0)*1000000 + din14(:, 1)*10000 + din14(:, 2)*100 + din14(:, 3)
   
    nnn     = dimsizes(timlab2)
    print(nnn)
    indxxx  = new(nnn, "integer", 0)
    do i = 0, nnn - 1
      indxxx(i)  = ind( timlab(0, :) .eq. timlab2(i) )     
    end do

  
    numx = new((/2, nday*ntim/), "float", 1.0e+35)
   
   bias            = numx
 ;  stdd            = numx

   ; numx(0, indxxx)     = prt5(:,ichn)
     numx(0, indxxx)     = cold_ang1(:,0)     
    bias(0, indxxx)    = cold_ang2(:,0)  
  ; stdd(0, indxxx)    = hot_ang2(:,0)
 
 ;   print(din12(:, ichn))

 ;   numx(1, indxxx)    = prt2(:,ichn)
 ;   bias(1, indxxx)    = din22(:, ichn)
 ;   stdd(1, indxxx)    = din23(:, ichn)
 ;   numx(2, indxxx)    = prt3(:,ichn)

 ;   numx(3, indxxx)    = prt4(:,ichn)
 ;   numx(4, indxxx)    = prt5(:,ichn)
    ;numx(1, indxxx)    = prt_avg(:,ichn)

    ;num2           = numx 
    ;num2(0, :)  = numx(1, :)*10000.  - numx(0, :)*10000.
 
    xaix       = ispan(0, nday*ntim-1, 1) 

    if ( nday .gt. 600 ) then
      xttt       = ind(mod(timlab(0, :), 10000) .eq. 101 .or. mod(timlab(0, :), 10000) .eq. 401 .or. mod(timlab(0, :), 10000) .eq. 701 .or. mod(timlab(0, :), 10000) .eq. 1001 )      
      if ( mod( timlab(0, nday-1), 10000 ) .eq. 1231 .or. mod( timlab(0, nday-1), 10000 ) .eq. 331 .or. mod( timlab(0, nday-1), 10000 ) .eq. 630 .or. mod( timlab(0, nday-1), 10000 ) .eq. 930 ) then
        nnnn       = dimsizes(xttt)
        xind       = new(nnnn+1, "integer", -9999)
        xind(0:nnnn-1)  = xttt
        xind(nnnn) = nday-1 
      else       
        xind       = xttt
      end if
      caix       = sprinti("%4.4i",mod(timlab(0, xind), 10000) )+"~C~"+sprinti("%4.4i",timlab(0, xind)/10000 )
      xmain      = xaix(xind)      
      xmino      = ind(mod(timlab(0, :), 100) .eq. 1 .or. mod(timlab(0, :), 100) .eq. 15 )
    end if
 
    if ( nday .lt. 200 ) then
      xttt       = ind(mod(timlab(0, :), 10000) .eq. 100 .or. mod(timlab(0, :), 10000) .eq. 1500 )
      nnnn       = dimsizes(xttt)
      xind       = new(nnnn+1, "integer", -9999)
      xind(0:nnnn-1)  = xttt
      xind(nnnn) = nday*ntim-1
      delete(xttt)
      caix       = sprinti("%4.4i",mod(timlab(0, xind), 1000000)/100 )+"~C~"+sprinti("%4.4i", timlab(0, xind)/1000000  )
      xttt       = ind( mod(timlab(0, :), 200) .eq. 0 )
      xmain      = xaix(xind)
      xmino      = xaix(xttt)
    end if
    print(xmain)
    print(caix)
 
;; plots
    _Font      = 4   
    wks = gsn_open_wks("png", fil_out)
    gsn_define_colormap(wks,"default")
    alphas             = (/"a)","b)","c)","d)","e) ","f) ","g) ","h) ","i) ", "j) ", "k) "/)     
    xyLTs              = (/.05,.05,.05,.05,.05,.05,.05,.05,.05,.05,.05,.05,.05,.05,.05,.05,.05,.05,.05/)*40.  
    xyLCs              = (/27,2, 3, 4,8,7,6,10,12,13,16,19,20,22,23,24,28/)
    xyDPs              = (/0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0/)
    plot               = new(4,graphic)

    do ilp1 = 0 , 0
      res                                = True      
      res@gsnMaximize                    = False               ; maximize pot in frame
      res@gsnFrame                       = False               ; don''t advance frame
      res@gsnDraw                        = False               ; don''t draw plot
      res@gsnPaperOrientation            = "portrait" 

      res@txFontThicknessF               = 2

      res@vpXF                           = 0.20
      res@vpHeightF                      = 0.30
      res@vpWidthF                       = 0.60

      res@xyMarkLineMode                 = "Lines"  ; "Markers", "MarkLines"
      res@xyLineThicknesses              = xyLTs    ; thicker line
      res@xyDashPatterns                 = xyDPs
      res@xyLineColors                   = xyLCs(:10)
      res@xyMarker                       = 16    ; 3 different markers
      res@xyMarkerColors                 = xyLCs(:10)
      res@xyMarkerSizeF                  = 0.005

      res@trXMinF                        = 0 
      res@trXMaxF                        = nday*ntim - 1
 
;;   For X-Top
      res@trXReverse                     = False        
      res@tmXTBorderOn                   = True
      res@tmXTOn                         = True
      res@tmXTLabelsOn                   = False
      
;;   For X-Bottom                         
      res@tmXBBorderOn                   = True
      res@tmXBOn                         = True
      res@tmXBLabelsOn                   = True
      res@tmXBLabelFont                  = _Font
      res@tmXBLabelFontHeightF           = 0.015
      res@tmXBLabelAngleF                = 0
      res@tmXBLabelFontThicknessF        = 2.0
      res@tmXBMode                       = "Explicit"
      res@tmXBValues                     = xmain
      res@tmXBLabels                     = caix
      res@tmXBMinorOn                    = True
      res@tmXBMinorValues                = xmino

;      res@trYMinF                        = 0 
;      res@trYMaxF                        = 3.0

;;  For Y-Right
      res@trYReverse                     = False
      res@tmYRBorderOn                   = True
      res@tmYROn                         = True
      res@tmYRLabelsOn                   = False
      
;;  For Y-Left      
      res@tmYLBorderOn                   = True
      res@tmYLOn                         = True
      res@tmYLLabelsOn                   = True
      res@tmYLLabelFont                  = _Font
      res@tmYLLabelFontHeightF           = 0.015
      res@tmYLLabelAngleF                = 0
      res@tmYLLabelFontThicknessF        = 2.0      
;      res@tmYLMode                       = "Explicit"
;      res@tmYLValues                     = ispan(160, 320, 20)
;      res@tmYLLabels                     = sprinti("%0.3i", ispan(160, 320, 20))       
;      res@tmYLMinorValues                = ispan(160, 320, 5)
;      res@tmYLMinorOn                    = True;


      res@gsnStringFont                  = _Font
      res@gsnStringFontHeightF           = 0.015           
;      res@gsnLeftStringOrthogonalPosF    = 0.03   

;; for tittles
      res@tiMainFont                     = _Font
      res@tiMainFontHeightF              = 0.012
      res@tiMainFontThicknessF           = 2.0
      res@tiXAxisString                  = ""
      res@tiXAxisFont                    = _Font
      res@tiXAxisFontHeightF             = 0.015
      res@tiXAxisFontThicknessF          = 2.0
      res@tiXAxisOffsetYF                = 0.00     ;; positive to up
      res@tiXAxisOffsetXF                = 0.0       ;; positive to right
      
      res@tiYAxisString                  = ""
      res@tiYAxisFont                    = _Font
      res@tiYAxisFontHeightF             = 0.016
      res@tiYAxisFontThicknessF          = 2.0      
      res@tiYAxisOffsetYF                = 0.0        ;; positive to up
      res@tiYAxisOffsetXF                = -0.02      ;; positive to right
      
     res@trYMinF                        = 155
     res@trYMaxF                        = 157
      
      res@vpYF                           = 0.90    
      print(numx)      
      plot(0)  = gsn_csm_xy(wks, xaix,numx,res)

      res@trYMinF                        = 164
      res@trYMaxF                        = 165
    ;  res@gsnLeftString                  = "b) BIAS"
      res@gsnCenterString                = "" 
   ;   res@gsnRightString                 = " K  "
      res@vpYF                           = 0.45  
      print(bias)  
    plot(1)  = gsn_csm_xy(wks, xaix,bias,res)  
   

     res@trYMinF                        = 265
     res@trYMaxF                        = 266 
     ;   res@gsnLeftString                  = "c) STDD"
      res@gsnCenterString                = "" 
    ;  res@gsnRightString                 = " K  "
      res@tmXBLabelsOn                   = False
      res@vpYF                           = 0.40
      res@tmXBLabelsOn                   = True
     ; print(stdd)
     ; plot(2)  = gsn_csm_xy(wks, xaix, stdd, res)         
  
    end do  
    
      LS1  = (/"cold_ang1"/)
      LS2  = (/"cold_ang2"/)
      gsres                    = True
      gsres@gsMarkerIndex      = 16
      gsres@gsMarkerThicknessF = 2.0

      lint = 0.45
      ladd = -0.01
      do i = 0,0
        respl                    = True
        respl@gsLineThicknessF   = 2.0
        respl@gsLineColor        = xyLCs(i)
        respl@gsLineThicknessF   = xyLTs(i)*2.
        respl@gsLineDashPattern  = xyDPs(i)
        gsn_polyline_ndc(wks, (/-0.03,0.03/)+lint*(i+1)+ladd, (/0.5,0.5/), respl)
         gsn_polyline_ndc(wks, (/-0.03,0.03/)+lint*(i+1)+ladd, (/0.015,0.015/), respl)
        gsres@gsMarkerColor      = xyLCs(i)

        restx                    = True
        restx@txFontHeightF      = 0.016
        restx@txFont             = _Font
        restx@txFontThicknessF   = 2
        restx@txJust             = "CenterLeft"
        gsn_text_ndc (wks, LS1(i), lint*(i+1) + 0.04+ladd ,0.5,restx)          
        gsn_text_ndc (wks, LS2(i), lint*(i+1) + 0.04+ladd ,0.015 ,restx)
        gsn_text_ndc (wks,fil_out, 0.15,0.95 ,restx)     
      end do     
      
      
    draw(plot)
    frame(wks)     
  end 
print(">>"+fil_out+".png is finish! >>") 

okstrs = (/fil_out,".","png",".","OK"/)
okline = str_concat(okstrs)
header = (/"--------------------------------", \
            okline, \
            "--------------------------------"/)
hlist = [/header/] 
write_table(okline, "w", hlist, "%s ") 





