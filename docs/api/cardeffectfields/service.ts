import { request } from '@umijs/max';
import { CardEffectFieldsAPI } from './data';

/** 创建卡牌效果模板 */
export async function createCardEffectFields(params: CardEffectFieldsAPI.CreateCardEffectFieldsParams) {
  return request<API.ApiResponse<string>>('/api/products/card-effect-fieldses', {
    method: 'POST',
    data: params,
  });
}

/** 创建卡牌效果模板（全参数） */
export async function createCardEffectFieldsWithAllFields(params: CardEffectFieldsAPI.CreateCardEffectFieldsWithAllFieldsParams) {
  return request<API.ApiResponse<string>>('/api/products/card-effect-fieldses/with-all-fields', {
    method: 'POST',
    data: params,
  });
}

/** 查询卡牌效果模板详情 */
export async function getCardEffectFieldsDetail(cardEffectFieldsId: string) {
  return request<API.ApiResponse<CardEffectFieldsAPI.CardEffectFieldsVO>>(`/api/products/card-effect-fieldses/${cardEffectFieldsId}`, {
    method: 'GET',
  });
}

/** 分页查询卡牌效果模板 */
export async function getCardEffectFieldsPage(params: CardEffectFieldsAPI.CardEffectFieldsPageParams) {
  return request<API.ApiResponse<API.PageData<CardEffectFieldsAPI.CardEffectFieldsVO>>>('/api/products/card-effect-fieldses', {
    method: 'GET',
    params,
  });
}

/** 修改模板名 */
export async function updateCardEffectFieldsTemplateName(cardEffectFieldsId: string, params: CardEffectFieldsAPI.UpdateCardEffectFieldsTemplateNameParams) {
  return request<API.ApiResponse<null>>(`/api/products/card-effect-fieldses/${cardEffectFieldsId}/template-name`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改效果字段模板 */
export async function updateCardEffectFieldsEffectFields(cardEffectFieldsId: string, params: CardEffectFieldsAPI.UpdateCardEffectFieldsEffectFieldsParams) {
  return request<API.ApiResponse<null>>(`/api/products/card-effect-fieldses/${cardEffectFieldsId}/effect-fields`, {
    method: 'PUT',
    data: params,
  });
}

/** 删除卡牌效果模板 */
export async function deleteCardEffectFields(cardEffectFieldsId: string) {
  return request<API.ApiResponse<null>>(`/api/products/card-effect-fieldses/${cardEffectFieldsId}`, {
    method: 'DELETE',
  });
}

 