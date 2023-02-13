subroutine output()
use all
implicit none
integer :: i,j,k
real(8) :: damfront, damh
real(8) :: g5a,g0,gc,g8a

! level set method, loss of volume/mass in percentage
write(p%fil%ls_mv,*)p%glb%time,100.0d0*(p%glb%imass-p%glb%mass)/p%glb%imass,100.0d0*(p%glb%ivol-p%glb%vol)/p%glb%ivol

!Drybed 
damfront = 0.0d0; damh=0.0d0
k=1
!$omp parallel do collapse(2), reduction(max:damfront)
do j = p%loc%js, p%loc%je
do i = p%loc%is, p%loc%ie
    if( p%loc%phi%now(i,j,k)*p%loc%phi%now(i+1,j,k) < 0.0d0 .and. p%loc%phi%now(i-1,j,k) > 0.0d0 .and. p%loc%phi%now(i-2,j,k) > 0.0d0 )then
        damfront = max( damfront, p%glb%x(i,j,k) + &
             p%glb%dx*abs(p%loc%phi%now(i,j,k))/( abs(p%loc%phi%now(i,j,k))+abs(p%loc%phi%now(i+1,j,k))) )
    endif
enddo
enddo   
!$omp end parallel do

i=1
!$omp parallel do collapse(2), reduction(max:damh)
do k = p%loc%ks, p%loc%ke
do j = p%loc%js, p%loc%je
    if( p%loc%phi%now(i,j,k)*p%loc%phi%now(i,j,k+1) < 0.0d0 .and. p%loc%phi%now(i,j,k-1)>0.0d0 .and. p%loc%phi%now(i,j,k-2)>0.0d0 )then
        damh = max( damh, p%glb%z(i,j,k) + &
            p%glb%dz*abs(p%loc%phi%now(i,j,k))/( abs(p%loc%phi%now(i,j,k))+abs(p%loc%phi%now(i,j,k+1))) )
    endif
enddo
enddo
!$omp end parallel do

write(p%fil%damdata, *)p%glb%time*p%glb%T, damfront*p%glb%L, damh*p%glb%L


! ! G5A, (x,y) = (0.18,1)
! j=p%glb%node_y/2
! i=int(0.18d0/p%glb%dx-0.5d0)+1
! do k = p%loc%ks, p%loc%ke-1
!     if( p%loc%phi%now(i,j,k) * p%loc%phi%now(i,j,k+1) < 0.0d0 )then
!         g5a = p%glb%z(i,j,k) + p%glb%dz*abs(p%loc%phi%now(i,j,k))/( abs(p%loc%phi%now(i,j,k))+abs(p%loc%phi%now(i,j,k+1))  )
!     endif
! enddo

! ! G0, (x,y) = (1,1)
! j=p%glb%node_y/2
! i=int(1.0d0/p%glb%dx-0.5d0)+1
! do k = p%loc%ks, p%loc%ke-1
!     if( p%loc%phi%now(i,j,k) * p%loc%phi%now(i,j,k+1) < 0.0d0 )then
!         g0 = p%glb%z(i,j,k) + p%glb%dz*abs(p%loc%phi%now(i,j,k))/( abs(p%loc%phi%now(i,j,k))+abs(p%loc%phi%now(i,j,k+1))  )
!     endif
! enddo

! ! G0, (x,y) = (0.505,1.65)
! j=int(1.65d0/p%glb%dx-0.5d0)+1
! i=int(0.505d0/p%glb%dx-0.5d0)+1
! do k = p%loc%ks, p%loc%ke-1
!     if( p%loc%phi%now(i,j,k) * p%loc%phi%now(i,j,k+1) < 0.0d0 )then
!         gc = p%glb%z(i,j,k) + p%glb%dz*abs(p%loc%phi%now(i,j,k))/( abs(p%loc%phi%now(i,j,k))+abs(p%loc%phi%now(i,j,k+1))  )
!     endif
! enddo

! ! g8a, (x,y) = (1.722,1)
! j=p%glb%node_y/2
! i=int(1.722d0/p%glb%dx-0.5d0)+1
! do k = p%loc%ks, p%loc%ke-1
!     if( p%loc%phi%now(i,j,k) * p%loc%phi%now(i,j,k+1) < 0.0d0 )then
!         g8a = p%glb%z(i,j,k) + p%glb%dz*abs(p%loc%phi%now(i,j,k))/( abs(p%loc%phi%now(i,j,k))+abs(p%loc%phi%now(i,j,k+1))  )
!     endif
! enddo

! write(p%fil%damdata, *)p%glb%time, g5a, g0, gc, g8a

end subroutine

subroutine print_NS_info()
use all 
implicit none

    write(*,'("Divergence :",2ES15.4)')p%glb%vel_div,p%glb%vel_sdiv
    write(*,'("L2 norm    :",ES15.4)')p%glb%ns_l2f
    write(*,'("Linf norm  :",ES15.4)')p%glb%ns_linf
    write(*,*)''
    write(*,'("PPE iters  :",I15)')p%glb%piter
    write(*,'("PPE error  :",ES15.4)')p%glb%ppe_linf
    write(*,*)''     

end subroutine

subroutine print_LS_info()
use all
implicit none

    write(*,'("LS,  Loss of mass  (%) :",ES15.4)')100.0d0*(p%glb%imass-p%glb%mass)/p%glb%imass
    write(*,'("LS,  Loss of volume(%) :",ES15.4)')100.0d0*(p%glb%ivol-p%glb%vol)/p%glb%ivol
    write(*,*)''
    if(p%glb%method==3)then
        write(*,'("VOF, Loss of mass  (%) :",ES15.4)')100.0d0*(p%glb%imassv-p%glb%massv)/p%glb%imassv
        write(*,'("VOF, Loss of volume(%) :",ES15.4)')100.0d0*(p%glb%ivolv-p%glb%volv)/p%glb%ivolv
        write(*,*)''
    endif

end subroutine

subroutine print_CPU_info()
use all 
implicit none
real(8) :: total, totald

    total = p%glb%ls_adv + p%glb%ls_red + p%glb%ns
    write(*,'("Total CPU time(s) :",F15.6)')total
    write(*,'(4A18)')"Inter. Adv.","Inter. Recon.","PPE","NS"
    write(*,'(F17.2,"%",F17.2,"%",F17.2,"%",F17.2,"%")')100.0d0*p%glb%ls_adv/total,100.0d0*p%glb%ls_red/total&
                                            &,100.0d0*p%glb%ppe/total,100.0d0*(p%glb%ns-p%glb%ppe)/total

end subroutine
