USE gabby
GO

CREATE OR ALTER VIEW tableau.attendance_dashboard AS

SELECT academic_year
      ,schoolid
      ,studentid
      ,student_number
      ,lastfirst
      ,grade_level
      ,school_level
      ,team
      ,enroll_status
      ,iep_status
      ,gender
      ,ethnicity
      ,section_number
      ,teacher_name
      ,calendardate
      ,membershipvalue
      ,is_present
      ,is_absent
      ,att_code
      ,is_tardy
      ,suspension_all
      ,n_A
      ,n_AD
      ,n_AE
      ,n_A_E
      ,n_CR
      ,n_CS
      ,n_D
      ,n_E
      ,n_EA
      ,n_ET
      ,n_EV
      ,n_ISS
      ,n_NM
      ,n_OS
      ,n_OSS
      ,n_OSSP
      ,n_PLE
      ,n_Q
      ,n_S
      ,n_SE
      ,n_T
      ,n_T10
      ,n_TE
      ,n_TLE
      ,n_U
      ,n_X
      ,term
      ,is_oss_running
      ,is_iss_running
      ,is_suspended_running
FROM gabby.tableau.attendance_dashboard_current_static

UNION ALL

SELECT academic_year
      ,schoolid
      ,studentid
      ,student_number
      ,lastfirst
      ,grade_level
      ,school_level
      ,team
      ,enroll_status
      ,iep_status
      ,gender
      ,ethnicity
      ,section_number
      ,teacher_name
      ,calendardate
      ,membershipvalue
      ,is_present
      ,is_absent
      ,att_code
      ,is_tardy
      ,suspension_all
      ,n_A
      ,n_AD
      ,n_AE
      ,n_A_E
      ,n_CR
      ,n_CS
      ,n_D
      ,n_E
      ,n_EA
      ,n_ET
      ,n_EV
      ,n_ISS
      ,n_NM
      ,n_OS
      ,n_OSS
      ,n_OSSP
      ,n_PLE
      ,n_Q
      ,n_S
      ,n_SE
      ,n_T
      ,n_T10
      ,n_TE
      ,n_TLE
      ,n_U
      ,n_X
      ,term
      ,is_oss_running
      ,is_iss_running
      ,is_suspended_running
FROM gabby.tableau.attendance_dashboard_archive