subroutine ns_solver
use all
implicit none
integer(8) :: cpustart, cpuend

call system_clock(cpustart)

call ns_init
call ns_ab_solver
call ns_check_convergence_div
call ibm_bc
call node_vel

call system_clock(cpuend)
p%glb%ns = p%glb%ns + real(cpuend-cpustart,kind=8)/real(p%glb%cpurate,kind=8)
    
end subroutine

subroutine ns_init
use all
!$ use omp_lib
implicit none
integer :: id,i,j,k

call rho_mu
call curv
    
end subroutine

subroutine ns_linearize
use all
!$ use omp_lib
implicit none
integer :: id,i,j,k

!$omp parallel do private(i,j,k)
do id = 0, p%glb%threads-1
    
    !$omp parallel do num_threads(p%glb%nthreads) collapse(3) private(i,j,k)
    do k = p%of(id)%loc%ks-p%glb%ghc, p%of(id)%loc%ke+p%glb%ghc
    do j = p%of(id)%loc%js-p%glb%ghc, p%of(id)%loc%je+p%glb%ghc
    do i = p%of(id)%loc%is-p%glb%ghc, p%of(id)%loc%ie+p%glb%ghc
        p%of(id)%loc%vel%x%tmp(i,j,k) = p%of(id)%loc%vel%x%now(i,j,k) 
        p%of(id)%loc%vel%y%tmp(i,j,k) = p%of(id)%loc%vel%y%now(i,j,k) 
        p%of(id)%loc%vel%z%tmp(i,j,k) = p%of(id)%loc%vel%z%now(i,j,k) 
    end do
    end do
    end do
    !$omp end parallel do
  
enddo       
!$omp end parallel do
        
end subroutine

subroutine ns_check_convergence_div
use all
!$ use omp_lib
implicit none
integer :: id,i,j,k
real(8) :: div, sumdiv
real(8) :: ux,vy,wz

div=0.0d0
sumdiv=0.0d0

!$omp parallel do private(i,j,k,ux,vy,wz), reduction(max:div), reduction(+:sumdiv)
do id = 0, p%glb%threads-1
    
    !$omp parallel do num_threads(p%glb%nthreads) collapse(3) &
    !$omp& private(i,j,k,ux,vy,wz), reduction(max:div), reduction(+:sumdiv)
    do k = p%of(id)%loc%ks, p%of(id)%loc%ke
    do j = p%of(id)%loc%js, p%of(id)%loc%je
    do i = p%of(id)%loc%is, p%of(id)%loc%ie
    
        ux = (p%of(id)%loc%vel%x%now(i,j,k)-p%of(id)%loc%vel%x%now(i-1,j,k))/p%glb%dx
        vy = (p%of(id)%loc%vel%y%now(i,j,k)-p%of(id)%loc%vel%y%now(i,j-1,k))/p%glb%dy
        wz = (p%of(id)%loc%vel%z%now(i,j,k)-p%of(id)%loc%vel%z%now(i,j,k-1))/p%glb%dz 
            
        div = max( div, abs(ux+vy+wz) ) 
        sumdiv = sumdiv + abs(ux+vy+wz)
                                        
    end do
    end do
    end do
    !$omp end parallel do
  
enddo   
!$omp end parallel do
  
p%glb%vel_sdiv = sumdiv / (p%glb%node_x*p%glb%node_y*p%glb%node_z)
p%glb%vel_div = div
    
end subroutine

subroutine ns_check_convergence_vel
use all
!$ use omp_lib
implicit none
integer :: id,i,j,k
real(8) :: linf, l2f

linf=0.0d0
l2f=0.0d0

!$omp parallel do private(i,j,k), reduction(max:linf), reduction(+:l2f)
do id = 0, p%glb%threads-1
    
    !$omp parallel do num_threads(p%glb%nthreads) collapse(3) private(i,j,k), reduction(max:linf), reduction(+:l2f)
    do k = p%of(id)%loc%ks, p%of(id)%loc%ke
    do j = p%of(id)%loc%js, p%of(id)%loc%je
    do i = p%of(id)%loc%is, p%of(id)%loc%ie
    
        linf = max(linf,abs(p%of(id)%loc%vel%x%now(i,j,k)-p%of(id)%loc%vel%x%tmp(i,j,k)))
        linf = max(linf,abs(p%of(id)%loc%vel%y%now(i,j,k)-p%of(id)%loc%vel%y%tmp(i,j,k)))
        linf = max(linf,abs(p%of(id)%loc%vel%z%now(i,j,k)-p%of(id)%loc%vel%z%tmp(i,j,k)))
        
        l2f = l2f + (p%of(id)%loc%vel%x%now(i,j,k)-p%of(id)%loc%vel%x%tmp(i,j,k))**2.0d0
        l2f = l2f + (p%of(id)%loc%vel%y%now(i,j,k)-p%of(id)%loc%vel%y%tmp(i,j,k))**2.0d0
        l2f = l2f + (p%of(id)%loc%vel%z%now(i,j,k)-p%of(id)%loc%vel%z%tmp(i,j,k))**2.0d0
                                        
    end do
    end do
    end do
    !$omp end parallel do
  
enddo   
!$omp end parallel do

l2f = dsqrt( l2f / (3.0d0*p%glb%node_x*p%glb%node_y*p%glb%node_z) )

p%glb%ns_linf = linf
p%glb%ns_l2f = l2f
    
end subroutine

subroutine node_vel
use all
implicit none
integer :: id,i,j,k

    !$omp parallel do private(i,j,k)
    do id = 0, p%glb%threads-1
        
        !$omp parallel do num_threads(p%glb%nthreads) collapse(3) private(i,j,k)
        do k = p%of(id)%loc%ks, p%of(id)%loc%ke
        do j = p%of(id)%loc%js, p%of(id)%loc%je
        do i = p%of(id)%loc%is, p%of(id)%loc%ie
            p%of(id)%loc%nvel%x%now(i,j,k) = 0.5d0 * ( p%of(id)%loc%vel%x%now(i-1,j,k) + p%of(id)%loc%vel%x%now(i,j,k) )
            p%of(id)%loc%nvel%y%now(i,j,k) = 0.5d0 * ( p%of(id)%loc%vel%y%now(i,j-1,k) + p%of(id)%loc%vel%y%now(i,j,k) )
            p%of(id)%loc%nvel%z%now(i,j,k) = 0.5d0 * ( p%of(id)%loc%vel%z%now(i,j,k-1) + p%of(id)%loc%vel%z%now(i,j,k) )
        end do
        end do
        end do
        !$omp end parallel do
     
    enddo       
    !$omp end parallel do

    call nvel_bc

end subroutine

subroutine ibm_bc
use all
implicit none
integer :: id,i,j,k,ii,jj,kk
real(8) :: x,y,z,solid

p%glb%ibm%z = p%glb%ibm%z + p%glb%ibm%w*p%glb%dt

!$omp parallel do private(i,j,k,ii,jj,kk,x,y,z)
do id = 0, p%glb%threads-1

    !$omp parallel do num_threads(p%glb%nthreads) collapse(3) private(i,j,k,ii,jj,kk,x,y,z)
    do k = p%of(id)%loc%ks, p%of(id)%loc%ke
    do j = p%of(id)%loc%js, p%of(id)%loc%je
    do i = p%of(id)%loc%is, p%of(id)%loc%ie

        p%of(id)%loc%solid%now(i,j,k) = 0.0d0

        do ii = 1, p%glb%ibm%ug
        do jj = 1, p%glb%ibm%ug
        do kk = 1, p%glb%ibm%ug
            
            x = 0.5d0*( p%glb%x(i,j,k)+p%glb%x(i-1,j,k) ) + real(ii,8)*p%glb%dx/real(p%glb%ibm%ug,8)
            y = 0.5d0*( p%glb%y(i,j,k)+p%glb%y(i,j-1,k) ) + real(jj,8)*p%glb%dy/real(p%glb%ibm%ug,8)
            z = 0.5d0*( p%glb%z(i,j,k)+p%glb%z(i,j,k-1) ) + real(kk,8)*p%glb%dz/real(p%glb%ibm%ug,8)

            if( x>5.0d0/3.0d0 .and. x<5.0d0/3.0d0+2.0d0*p%glb%dx .and. z>p%glb%ibm%z )then
                p%of(id)%loc%solid%now(i,j,k) = p%of(id)%loc%solid%now(i,j,k) + 1.0d0/real(p%glb%ibm%ug,8)**3.0d0
            endif
            
        end do
        end do
        end do

    enddo
    enddo
    enddo
    !$omp end parallel do

    call p%of(id)%bc(0,p%of(id)%loc%solid%now)

enddo
!$omp end parallel do

call pt%solid%sync

!$omp parallel do private(i,j,k,solid)
do id = 0, p%glb%threads-1

    !$omp parallel do num_threads(p%glb%nthreads) collapse(3) private(i,j,k,solid)
    do k = p%of(id)%loc%ks, p%of(id)%loc%ke
    do j = p%of(id)%loc%js, p%of(id)%loc%je
    do i = p%of(id)%loc%is, p%of(id)%loc%ie

        solid = 0.5d0*( p%of(id)%loc%solid%now(i,j,k)+p%of(id)%loc%solid%now(i+1,j,k) )
        p%of(id)%loc%vel%x%now(i,j,k) = (1.0-solid)*p%of(id)%loc%vel%x%now(i,j,k)

        solid = 0.5d0*( p%of(id)%loc%solid%now(i,j,k)+p%of(id)%loc%solid%now(i,j+1,k) )
        p%of(id)%loc%vel%y%now(i,j,k) = (1.0-solid)*p%of(id)%loc%vel%y%now(i,j,k)

        solid = 0.5d0*( p%of(id)%loc%solid%now(i,j,k)+p%of(id)%loc%solid%now(i,j,k+1) )
        p%of(id)%loc%vel%z%now(i,j,k) = (1.0-solid)*p%of(id)%loc%vel%z%now(i,j,k) + solid*p%glb%ibm%w

    enddo
    enddo
    enddo
    !$omp end parallel do


enddo
!$omp end parallel do

end subroutine

