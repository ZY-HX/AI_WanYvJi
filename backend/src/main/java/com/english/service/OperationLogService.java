package com.english.service;

import com.english.entity.OperationLog;
import com.english.mapper.OperationLogMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class OperationLogService {

    private final OperationLogMapper operationLogMapper;

    @Transactional(rollbackFor = Exception.class)
    public void createLog(Long adminId, String operationType, String targetType, Long targetId, String details,
                          String ipAddress) {
        OperationLog operationLog = new OperationLog();
        operationLog.setAdminId(adminId);
        operationLog.setOperationType(operationType);
        operationLog.setTargetType(targetType);
        operationLog.setTargetId(targetId);
        operationLog.setDetails(details);
        operationLog.setIpAddress(ipAddress);
        operationLogMapper.insert(operationLog);
    }
}
