import { request } from '@umijs/max';
import { ProductInfoAPI } from './data';
import { DynamicFieldTemplate } from '@/components/DynamicField/types';

/** 创建商品信息 */
export async function createProductInfo(params: ProductInfoAPI.CreateProductInfoParams) {
  return request<API.ApiResponse<string>>('/api/products/product-infos', {
    method: 'POST',
    data: params,
  });
}

/** 创建商品信息（全参数） */
export async function createProductInfoWithAllFields(params: ProductInfoAPI.CreateProductInfoWithAllFieldsParams) {
  return request<API.ApiResponse<string>>('/api/products/product-infos/with-all-fields', {
    method: 'POST',
    data: params,
  });
}

/** 查询商品信息详情 */
export async function getProductInfoDetail(productInfoId: string) {
  return request<API.ApiResponse<ProductInfoAPI.ProductInfoVO>>(`/api/products/product-infos/${productInfoId}`, {
    method: 'GET',
  });
}

/** 分页查询商品信息 */
export async function getProductInfoPage(params: ProductInfoAPI.ProductInfoPageParams) {
  return request<API.ApiResponse<API.PageData<ProductInfoAPI.ProductInfoVO>>>('/api/products/product-infos', {
    method: 'GET',
    params,
  });
}

/** 根据ID列表查询商品信息 */
export async function getProductInfoByIds(ids: string[]) {
  return request<API.ApiResponse<ProductInfoAPI.ProductInfoVO[]>>('/api/products/product-infos/batch', {
    method: 'GET',
    params: { ids },
  });
}

/** 修改名称 */
export async function updateProductInfoName(productInfoId: string, params: ProductInfoAPI.UpdateProductInfoNameParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/name`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改编码 */
export async function updateProductInfoCode(productInfoId: string, params: ProductInfoAPI.UpdateProductInfoCodeParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/code`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改等级 */
export async function updateProductInfoLevel(productInfoId: string, params: ProductInfoAPI.UpdateProductInfoLevelParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/level`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改建议售价 */
export async function updateProductInfoSuggestedPrice(productInfoId: string, params: ProductInfoAPI.UpdateProductInfoSuggestedPriceParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/suggested-price`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改卡片语言 */
export async function updateProductInfoCardLanguage(productInfoId: string, params: ProductInfoAPI.UpdateProductInfoCardLanguageParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/card-language`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改类型 */
export async function updateProductInfoType(productInfoId: string, params: ProductInfoAPI.UpdateProductInfoTypeParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/type`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改卡牌效果模板 */
export async function updateProductInfoCardEffectTemplate(productInfoId: string, params: ProductInfoAPI.UpdateProductInfoCardEffectTemplateParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/card-effect-template`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改卡牌效果 */
export async function updateProductInfoCardEffects(productInfoId: string, params: ProductInfoAPI.UpdateProductInfoCardEffectsParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/card-effects`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改图片 */
export async function updateProductInfoImages(productInfoId: string, params: ProductInfoAPI.UpdateProductInfoImagesParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/images`, {
    method: 'PUT',
    data: params,
  });
}

/** 添加所属类目 */
export async function addProductInfoCategories(productInfoId: string, params: ProductInfoAPI.AddProductInfoCategoriesParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/categories`, {
    method: 'POST',
    data: params,
  });
}

/** 移除所属类目 */
export async function removeProductInfoCategories(productInfoId: string, params: ProductInfoAPI.RemoveProductInfoCategoriesParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}/categories`, {
    method: 'DELETE',
    data: params,
  });
}

/** 删除商品信息 */
export async function deleteProductInfo(productInfoId: string) {
  return request<API.ApiResponse<null>>(`/api/products/product-infos/${productInfoId}`, {
    method: 'DELETE',
  });
}

/** 获取卡牌效果动态字段模板 */
export async function getProductInfoCardEffectsTemplates(cardEffectTemplateId: string) {
  return request<API.ApiResponse<DynamicFieldTemplate[]>>(`/api/products/product-infos/card-effects/templates`, {
    method: 'GET',
    params: { cardEffectTemplateId },
  });
}

 