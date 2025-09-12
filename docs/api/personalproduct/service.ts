import { request } from '@umijs/max';
import { PersonalProductAPI } from './data';

/** 创建个人商品 */
export async function createPersonalProduct(params: PersonalProductAPI.CreatePersonalProductParams) {
  return request<API.ApiResponse<string>>('/api/products/personal-products', {
    method: 'POST',
    data: params,
  });
}

/** 创建个人商品（全参数） */
export async function createPersonalProductWithAllFields(params: PersonalProductAPI.CreatePersonalProductWithAllFieldsParams) {
  return request<API.ApiResponse<string>>('/api/products/personal-products/with-all-fields', {
    method: 'POST',
    data: params,
  });
}

/** 查询个人商品详情 */
export async function getPersonalProductDetail(personalProductId: string) {
  return request<API.ApiResponse<PersonalProductAPI.PersonalProductVO>>(`/api/products/personal-products/${personalProductId}`, {
    method: 'GET',
  });
}

/** 分页查询个人商品 */
export async function getPersonalProductPage(params: PersonalProductAPI.PersonalProductPageParams) {
  return request<API.ApiResponse<API.PageData<PersonalProductAPI.PersonalProductVO>>>('/api/products/personal-products', {
    method: 'GET',
    params,
  });
}

/** 根据ID列表查询个人商品 */
export async function getPersonalProductByIds(ids: string[]) {
  return request<API.ApiResponse<PersonalProductAPI.PersonalProductVO[]>>('/api/products/personal-products/batch', {
    method: 'GET',
    params: { ids },
  });
}

/** 修改商品信息 */
export async function updatePersonalProductProductInfo(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductProductInfoParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/product-info`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改价格 */
export async function updatePersonalProductPrice(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductPriceParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/price`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改备注 */
export async function updatePersonalProductNotes(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductNotesParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/notes`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改是否主图 */
export async function updatePersonalProductIsMainImage(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductIsMainImageParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/is-main-image`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改主人 */
export async function updatePersonalProductOwner(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductOwnerParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/owner`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改类型 */
export async function updatePersonalProductType(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductTypeParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/type`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改状态 */
export async function updatePersonalProductStatus(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductStatusParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/status`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改评级卡 */
export async function updatePersonalProductRatedCard(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductRatedCardParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/rated-card`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改数量 */
export async function updatePersonalProductQuantity(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductQuantityParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/quantity`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改品相 */
export async function updatePersonalProductCondition(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductConditionParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/condition`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改限时价格 */
export async function updatePersonalProductLimitedTimePrice(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductLimitedTimePriceParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/limited-time-price`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改截止时间 */
export async function updatePersonalProductDeadline(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductDeadlineParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/deadline`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改打包商品 */
export async function updatePersonalProductBundleProduct(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductBundleProductParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/bundle-product`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改图片 */
export async function updatePersonalProductImages(personalProductId: string, params: PersonalProductAPI.UpdatePersonalProductImagesParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/images`, {
    method: 'PUT',
    data: params,
  });
}

/** 删除个人商品 */
export async function deletePersonalProduct(personalProductId: string) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}`, {
    method: 'DELETE',
  });
}

 