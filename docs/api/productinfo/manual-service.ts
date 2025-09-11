import { request } from '@umijs/max';
import { ProductInfoAPI } from '../../../products/productinfo/data';

/** 手动分页查询商品信息参数（合并名称查询） */
export interface ProductInfoManualPageParams extends Omit<ProductInfoAPI.ProductInfoPageParams, 'nameChinese' | 'nameEnglish' | 'nameJapanese' | 'level'> {
  /** 名称（合并查询中文名、英文名、日文名） */
  name?: string;
  /** 等级（支持多个值的完全匹配查询） */
  level?: string[];
}

/** 查询所有商品信息的 distinct level 值 */
export async function getProductInfoDistinctLevels() {
  return request<API.ApiResponse<string[]>>('/api/products/product-infos/levels/distinct', {
    method: 'GET',
  });
}

/** 分页查询商品信息（使用合并名称查询） */
export async function getProductInfoPageByName(params: ProductInfoManualPageParams) {
  return request<API.ApiResponse<API.PageData<ProductInfoAPI.ProductInfoVO>>>('/api/products/product-infos/page-by-name', {
    method: 'GET',
    params,
  });
}