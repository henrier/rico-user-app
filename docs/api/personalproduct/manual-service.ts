import { request } from '@umijs/max';
import { PersonalProductAPI } from '../../../products/personalproduct/data';
import { ProductCategoryAPI } from '../../../products/productcategory/data';
import { RatingCompanyAPI } from '../../../products/ratingcompany/data';

/** 根据查询条件统计数量（支持跨聚合查询） */
/** 用于上架状态标签选择 tab 旁的统计数值，携带 owner 和 status 及其他筛选条件发起查询 */
export async function countPersonalProductsByCondition(params: PersonalProductManualPageParams & ProductInfoManualPageParams & ProductCategoryAPI.ProductCategoryPageParams) {
  return request<API.ApiResponse<number>>('/api/products/personal-products/count', {
    method: 'GET',
    params,
  });
}

/** 分页查询个人商品（支持多字段排序和跨聚合查询） */
/** 携带 owner 和 status 及其他筛选条件发起查询，二级SPU类目、 SPU 的 level、四级类目等其他聚合的查询条件可一并传递*/
/** 升序：asc   降序：desc */
export async function getPersonalProductsPageWithSort(params: PersonalProductManualPageParams & ProductInfoManualPageParams & ProductCategoryAPI.ProductCategoryPageParams & {
  current?: number;
  pageSize?: number;
  sortFields?: string[];
  sortDirections?: string[];
}) {
  return request<API.ApiResponse<API.PageData<PersonalProductAPI.PersonalProductVO>>>('/api/products/personal-products/page-with-sort', {
    method: 'GET',
    params,
  });
}

/** 查询指定用户店铺的所有个人商品的 distinct 的 ratedCard.cardScore 值 */
/** 用于获取筛选弹窗的备选数据 */
export async function getDistinctCardScoresByOwner(ownerId: string) {
  return request<API.ApiResponse<string[]>>('/api/products/personal-products/card-scores/distinct', {
    method: 'GET',
    params: { ownerId },
  });
}

/** 查询指定店铺的所有个人商品的 distinct 的 productInfo 值，并进一步查询这些 productInfo 的 distinct 的 level 值 */
/** 用于获取筛选弹窗的备选数据 */
export async function getDistinctLevelsByOwner(ownerId: string) {
  return request<API.ApiResponse<string[]>>('/api/products/personal-products/levels/distinct', {
    method: 'GET',
    params: { ownerId },
  });
}

/** 查询指定店铺的所有个人商品的 distinct 的 productInfo 值，并进一步查询这些 productInfo 的 distinct 的 categories 值 */
/** 用于获取筛选弹窗的备选数据 */
export async function getDistinctCategoriesByOwner(ownerId: string) {
  return request<API.ApiResponse<ProductCategoryAPI.ProductCategoryVO[]>>('/api/products/personal-products/categories/distinct', {
    method: 'GET',
    params: { ownerId },
  });
}

/** 查询指定店铺的所有个人商品的 distinct 的 ratedCard.ratingCompany 值 */
/** 用于获取筛选弹窗的备选数据 */
export async function getDistinctRatingCompaniesByOwner(ownerId: string) {
  return request<API.ApiResponse<RatingCompanyAPI.RatingCompanyVO[]>>('/api/products/personal-products/rating-companies/distinct', {
    method: 'GET',
    params: { ownerId },
  });
}

/** 个人商品手动查询参数（支持跨聚合查询） */
export interface PersonalProductManualPageParams extends Omit<PersonalProductAPI.PersonalProductPageParams, 'ratedCardCardScore' | 'ratedCardRatingCompany' | 'status' | 'type'> {
  /** 评级卡 - 卡牌评分（支持多个值） */
  ratedCardCardScore?: string[];
  /** 评级卡 - 评级公司（支持多个值） */
  ratedCardRatingCompany?: string[];
  /** 状态（支持多个值） */
  status?: string[];
  /** 类型（支持多个值） */
  type?: string[];
}

/** SPU查询参数（用于跨聚合查询） */
export interface ProductInfoManualPageParams {
  /** 名称（合并查询中文名、英文名、日文名） */
  name?: string;
  /** 编码 */
  code?: string;
  /** 等级（支持多个值的完全匹配查询） */
  level?: string[];
  /** 建议售价最小值 */
  minSuggestedPrice?: number;
  /** 建议售价最大值 */
  maxSuggestedPrice?: number;
  /** 卡片语言 */
  cardLanguage?: string;
  /** 所属类目（支持多个值） */
  categories?: string[];
  /** 卡牌效果模板 */
  cardEffectTemplate?: string;
  /** 字段名（模糊查询） */
  fieldName?: string;
  /** 字段类型 */
  fieldType?: string;
  /** 显示名称（模糊查询） */
  displayName?: string;
  /** 字段值（模糊查询） */
  fieldValue?: string;
  /** 图片 */
  images?: string[];
  /** 创建时间范围开始 */
  createdAtStart?: string;
  /** 创建时间范围结束 */
  createdAtEnd?: string;
  /** 更新时间范围开始 */
  updatedAtStart?: string;
  /** 更新时间范围结束 */
  updatedAtEnd?: string;
  /** 创建者 */
  createdBy?: string;
  /** 更新者 */
  updatedBy?: string;
}

/** 个人商品手动创建参数（移动端专用） */
export interface CreatePersonalProductManualParams {
  /** 商品类型（必填） */
  type: PersonalProductAPI.TypeKey;
  /** 主人ID（必填） */
  owner: string;
  /** 商品信息ID（必填） */
  productInfoId: string;
  /** 品相 */
  condition?: PersonalProductAPI.ConditionKey;
  /** 评级卡 */
  ratedCard?: PersonalProductAPI.RatedCard;
  /** 价格 */
  price?: number;
  /** 库存 */
  quantity?: number;
  /** 备注 */
  notes?: string;
  /** 图片 */
  images?: string[];
  /** 是否主图 */
  isMainImage?: boolean;
  // 注意：status 字段不包含在创建参数中，默认为上架状态
}

/** 个人商品手动批量创建参数（移动端专用） */
export interface BatchCreatePersonalProductManualParams {
  /** 商品类型（必填） */
  type: PersonalProductAPI.TypeKey;
  /** 主人ID（必填） */
  owner: string;
  /** 商品信息ID（必填） */
  productInfoId: string;
  /** 品相 */
  condition?: PersonalProductAPI.ConditionKey;
  /** 评级卡 */
  ratedCard?: PersonalProductAPI.RatedCard;
  /** 价格 */
  price?: number;
  /** 库存 */
  quantity?: number;
  /** 备注 */
  notes?: string;
  /** 图片 */
  images?: string[];
  /** 是否主图 */
  isMainImage?: boolean;
  /** 商品状态（批量创建时可指定，默认为已上架） */
  status?: PersonalProductAPI.StatusKey;
}

/** 个人商品手动整体更新参数（移动端专用） */
export interface UpdatePersonalProductManualParams {
  /** 品相 */
  condition?: PersonalProductAPI.ConditionKey;
  /** 评级卡 */
  ratedCard?: PersonalProductAPI.RatedCard;
  /** 价格 */
  price?: number;
  /** 库存 */
  quantity?: number;
  /** 备注 */
  notes?: string;
  /** 图片 */
  images?: string[];
  /** 状态 */
  status?: PersonalProductAPI.StatusKey;
  /** 是否主图 */
  isMainImage?: boolean;
}

/** 创建个人商品（移动端专用） */
export async function createPersonalProductForMobile(params: CreatePersonalProductManualParams) {
  return request<API.ApiResponse<string>>('/api/products/personal-products/mobile-create', {
    method: 'POST',
    data: params,
  });
}

/** 批量创建个人商品（移动端专用） */
export async function batchCreatePersonalProductForMobile(paramsList: BatchCreatePersonalProductManualParams[]) {
  return request<API.ApiResponse<string[]>>('/api/products/personal-products/batch-mobile-create', {
    method: 'POST',
    data: paramsList,
  });
}

/** 整体更新个人商品（移动端专用） */
export async function updatePersonalProductForMobile(personalProductId: string, params: UpdatePersonalProductManualParams) {
  return request<API.ApiResponse<null>>(`/api/products/personal-products/${personalProductId}/mobile-update`, {
    method: 'PUT',
    data: params,
  });
}

/** 批量整体更新个人商品（移动端专用），批量上架下架 */
export async function batchUpdatePersonalProductForMobile(paramsList: (UpdatePersonalProductManualParams & { id: string })[]) {
  return request<API.ApiResponse<null>>('/api/products/personal-products/batch-mobile-update', {
    method: 'POST',
    data: paramsList,
  });
}

/** 批量删除个人商品 */
export async function batchDeletePersonalProduct(ids: string[]) {
  return request<API.ApiResponse<null>>('/api/products/personal-products/batch-delete', {
    method: 'DELETE',
    data: ids,
  });
}
