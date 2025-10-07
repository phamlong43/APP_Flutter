# Script để thay thế tất cả API endpoints
Get-ChildItem -Recurse -Include "*.dart" | ForEach-Object {
     = Get-Content .FullName -Raw
    if ( -match "10\.0\.2\.2") {
        Write-Host "Updating: "
        
        # Thay thế các endpoints cơ bản
         =  -replace "http://10\.0\.2\.2:8080/users", "ApiEndpoints.usersUrl"
         =  -replace "http://10\.0\.2\.2:8080/tasks", "ApiEndpoints.tasksUrl" 
         =  -replace "http://10\.0\.2\.2:8080/tasks/all", "ApiEndpoints.allTasksUrl"
         =  -replace "http://10\.0\.2\.2:8080/tasks/update-status", "ApiEndpoints.updateTaskStatusUrl"
         =  -replace "http://10\.0\.2\.2:8080/api/attendance", "ApiEndpoints.attendanceUrl"
         =  -replace "http://10\.0\.2\.2:8080/attendance", "ApiEndpoints.attendanceAltUrl"
        
        Set-Content .FullName 
    }
}
