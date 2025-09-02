import { request } from '@umijs/max';
import { ProductCategoryAPI } from './data';

/** 创建商品类目 */
export async function createProductCategory(params: ProductCategoryAPI.CreateProductCategoryParams) {
  return request<API.ApiResponse<string>>('/api/products/product-categories', {
    method: 'POST',
    data: params,
  });
}

/** 创建商品类目（全参数） */
export async function createProductCategoryWithAllFields(params: ProductCategoryAPI.CreateProductCategoryWithAllFieldsParams) {
  return request<API.ApiResponse<string>>('/api/products/product-categories/with-all-fields', {
    method: 'POST',
    data: params,
  });
}

/** 查询商品类目详情 */
export async function getProductCategoryDetail(productCategoryId: string) {
  return request<API.ApiResponse<ProductCategoryAPI.ProductCategoryVO>>(`/api/products/product-categories/${productCategoryId}`, {
    method: 'GET',
  });
}

/** 分页查询商品类目 */
export async function getProductCategoryPage(params: ProductCategoryAPI.ProductCategoryPageParams) {
  return request<API.ApiResponse<API.PageData<ProductCategoryAPI.ProductCategoryVO>>>('/api/products/product-categories', {
    method: 'GET',
    params,
  });
}

/** 修改名称 */
export async function updateProductCategoryName(productCategoryId: string, params: ProductCategoryAPI.UpdateProductCategoryNameParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-categories/${productCategoryId}/name`, {
    method: 'PUT',
    data: params,
  });
}

/** 修改图片 */
export async function updateProductCategoryImages(productCategoryId: string, params: ProductCategoryAPI.UpdateProductCategoryImagesParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-categories/${productCategoryId}/images`, {
    method: 'PUT',
    data: params,
  });
}

/** 添加类目类型 */
export async function addProductCategoryCategoryTypes(productCategoryId: string, params: ProductCategoryAPI.AddProductCategoryCategoryTypesParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-categories/${productCategoryId}/category-types`, {
    method: 'POST',
    data: params,
  });
}

/** 移除类目类型 */
export async function removeProductCategoryCategoryTypes(productCategoryId: string, params: ProductCategoryAPI.RemoveProductCategoryCategoryTypesParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-categories/${productCategoryId}/category-types`, {
    method: 'DELETE',
    data: params,
  });
}

/** 添加父类目 */
export async function addProductCategoryParentCategories(productCategoryId: string, params: ProductCategoryAPI.AddProductCategoryParentCategoriesParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-categories/${productCategoryId}/parent-categories`, {
    method: 'POST',
    data: params,
  });
}

/** 移除父类目 */
export async function removeProductCategoryParentCategories(productCategoryId: string, params: ProductCategoryAPI.RemoveProductCategoryParentCategoriesParams) {
  return request<API.ApiResponse<null>>(`/api/products/product-categories/${productCategoryId}/parent-categories`, {
    method: 'DELETE',
    data: params,
  });
}

/** 删除商品类目 */
export async function deleteProductCategory(productCategoryId: string) {
  return request<API.ApiResponse<null>>(`/api/products/product-categories/${productCategoryId}`, {
    method: 'DELETE',
  });
} 