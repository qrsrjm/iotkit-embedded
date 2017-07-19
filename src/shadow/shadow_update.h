
#ifndef _ALIOT_SHADOW_UPDATE_H_
#define _ALIOT_SHADOW_UPDATE_H_

#include "iot_import.h"
#include "utils_error.h"

#include "shadow.h"
#include "shadow_config.h"
#include "shadow_common.h"


iotx_update_ack_wait_list_pt iotx_shadow_update_wait_ack_list_add(
            iotx_shadow_pt pshadow,
            const char *token,
            size_t token_len,
            iotx_update_cb_fpt cb,
            void *pcontext,
            uint32_t timeout);

void iotx_shadow_update_wait_ack_list_remove(iotx_shadow_pt pshadow, iotx_update_ack_wait_list_pt element);

void iotx_ds_update_wait_ack_list_handle_expire(iotx_shadow_pt pshadow);

void iotx_ds_update_wait_ack_list_handle_response(
            iotx_shadow_pt pshadow,
            const char *json_doc,
            size_t json_doc_len);


#endif /* _ALIOT_SHADOW_UPDATE_H_ */